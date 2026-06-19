import asyncio
import time
import json
import base64
import cv2
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Header, HTTPException, Request
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.state import state, Command
from app.processors.yolo_detector import YoloDetector
from app.processors.gesture_detector import GestureDetector
from app.decision import decide
from app.overlay import draw_overlay
from app.frame_ingest import ingest_frame
from app.command_sender import command_hub
from app.telemetry import telemetry_hub
from app.logger_session import session_logger

yolo: YoloDetector | None = None
gesture: GestureDetector | None = None

def _check_auth(x_api_key: str | None):
    if x_api_key != settings.api_key:
        raise HTTPException(401, "bad api key")

async def processing_loop():
    """Runs YOLO + MediaPipe + decision at target_fps."""
    period = 1.0 / settings.target_fps
    frame_count = 0
    last_sec = time.time()
    last_processed_ts = 0.0
    
    while True:
        t_start = time.time()
        frame = state.latest_frame
        
        # Skip if no new frame since last loop
        if frame is None or state.latest_frame_ts == last_processed_ts:
            await asyncio.sleep(0.02)
            continue
        last_processed_ts = state.latest_frame_ts
        
        loop = asyncio.get_event_loop()
        yolo_task = loop.run_in_executor(None, yolo.detect, frame)
        gesture_task = loop.run_in_executor(None, gesture.detect, frame)
        (detections, yolo_ms), (gesture_res, gesture_ms) = await asyncio.gather(yolo_task, gesture_task)
        
        state.detections = detections
        state.gesture = gesture_res
        cmd = decide(detections, gesture_res, state.mode, state.manual_input)
        state.last_command = cmd
        
        state.metrics["yolo_ms"] = yolo_ms
        state.metrics["gesture_ms"] = gesture_ms
        state.metrics["inference_ms"] = yolo_ms + gesture_ms
        
        await command_hub.broadcast(cmd)
        await telemetry_hub.broadcast(_telemetry_payload(frame))
        await session_logger.log(frame, detections, gesture_res, cmd)
        
        frame_count += 1
        if time.time() - last_sec >= 1.0:
            state.metrics["fps"] = frame_count / (time.time() - last_sec)
            frame_count = 0
            last_sec = time.time()
        
        elapsed = time.time() - t_start
        await asyncio.sleep(max(0, period - elapsed))

def _telemetry_payload(frame):
    annotated = draw_overlay(frame, state.detections, state.gesture, state.last_command, state.metrics)
    ok, buf = cv2.imencode(".jpg", annotated, [cv2.IMWRITE_JPEG_QUALITY, 70])
    img_b64 = base64.b64encode(buf).decode() if ok else ""
    return {
        "frame": img_b64,
        "detections": [
            {"label": d.label, "conf": round(d.confidence, 2),
             "dist": round(d.distance_m, 2), "zone": d.zone, "bbox": d.bbox}
            for d in state.detections
        ],
        "gesture": {"name": state.gesture.name, "conf": state.gesture.confidence},
        "command": {"action": state.last_command.action, "speed": state.last_command.speed,
                    "reason": state.last_command.reason},
        "mode": state.mode,
        "metrics": state.metrics,
    }

@asynccontextmanager
async def lifespan(app: FastAPI):
    global yolo, gesture
    yolo = YoloDetector()
    gesture = GestureDetector()
    task = asyncio.create_task(processing_loop())
    yield
    task.cancel()

app = FastAPI(lifespan=lifespan)

# ============================================================
# Pi-facing endpoints
# ============================================================

@app.post("/frame")
async def post_frame(
    request: Request,
    x_api_key: str | None = Header(default=None),
    x_capture_ts_ms: float | None = Header(default=None),
):
    """Pi posts raw JPEG bytes here. Returns latest command immediately
    so the Pi gets a piggyback response (one round trip per frame)."""
    _check_auth(x_api_key)
    body = await request.body()
    result = await ingest_frame(body, x_capture_ts_ms)
    # Piggyback the latest command in the response — Pi doesn't need a second call
    result["command"] = command_hub.get_latest()
    return result

@app.get("/command")
async def get_command(x_api_key: str | None = Header(default=None)):
    """Optional alternate path: Pi can poll for commands separately."""
    _check_auth(x_api_key)
    return command_hub.get_latest()

# ============================================================
# Website-facing endpoints (no API key — restrict via firewall or add auth)
# ============================================================

@app.websocket("/ws/dashboard")
async def ws_dash(ws: WebSocket):
    await ws.accept()
    await telemetry_hub.register(ws)
    try:
        while True:
            msg = await ws.receive_json()
            if msg.get("type") == "mode":
                state.mode = msg["value"]
            elif msg.get("type") == "manual":
                state.manual_input = Command(
                    action=msg["action"], speed=msg.get("speed", 0.4),
                    reason="manual_ui", timestamp=time.time(),
                )
    except WebSocketDisconnect:
        await telemetry_hub.unregister(ws)

@app.get("/health")
async def health():
    return {
        "ok": True, "mode": state.mode,
        "fps": state.metrics.get("fps", 0),
        "last_frame_age_ms": (time.time() - state.latest_frame_ts) * 1000 if state.latest_frame_ts else None,
    }

@app.get("/snapshot")
async def snapshot():
    """Latest annotated frame as JPEG, for quick browser checks."""
    from fastapi.responses import Response
    if state.latest_frame is None:
        raise HTTPException(503, "no frame yet")
    annotated = draw_overlay(state.latest_frame, state.detections,
                              state.gesture, state.last_command, state.metrics)
    ok, buf = cv2.imencode(".jpg", annotated)
    return Response(content=buf.tobytes(), media_type="image/jpeg")

app.mount("/", StaticFiles(directory="static", html=True), name="static")
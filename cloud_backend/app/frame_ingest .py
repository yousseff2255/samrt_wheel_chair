import time
import cv2
import numpy as np
from fastapi import HTTPException
from app.state import state
from app.config import settings

async def ingest_frame(image_bytes: bytes, capture_ts_ms: float | None = None) -> dict:
    """Decode and store an incoming frame. Returns metrics."""
    if not image_bytes:
        raise HTTPException(400, "empty body")
    
    t_recv = time.time()
    
    # Age check — if the Pi sends us a stale frame, drop it
    if capture_ts_ms is not None:
        age_ms = t_recv * 1000 - capture_ts_ms
        if age_ms > settings.max_frame_age_ms:
            return {"dropped": True, "reason": "stale", "age_ms": age_ms}
    
    arr = np.frombuffer(image_bytes, dtype=np.uint8)
    frame = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    if frame is None:
        raise HTTPException(400, "decode failed")
    
    # Resize to expected dims for consistent inference
    if frame.shape[:2] != (settings.frame_height, settings.frame_width):
        frame = cv2.resize(frame, (settings.frame_width, settings.frame_height))
    
    state.latest_frame = frame
    state.latest_frame_ts = t_recv
    
    if capture_ts_ms is not None:
        state.metrics["pi_to_gcp_ms"] = t_recv * 1000 - capture_ts_ms
    
    return {"dropped": False, "received_at": t_recv}
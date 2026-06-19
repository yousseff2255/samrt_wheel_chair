import os, json, time, asyncio, cv2
from app.config import settings

class SessionLogger:
    def __init__(self):
        self.session_dir = f"sessions/session_{int(time.time())}"
        os.makedirs(f"{self.session_dir}/frames", exist_ok=True)
        self.events_path = f"{self.session_dir}/events.jsonl"
        self.frame_idx = 0
    
    async def log(self, frame, detections, gesture, cmd):
        if not settings.log_to_disk: return
        # Only save frames on "interesting" events to save space
        interesting = cmd.action == "stop" and "obstacle" in cmd.reason
        if interesting or self.frame_idx % 30 == 0:
            path = f"{self.session_dir}/frames/{self.frame_idx:06d}.jpg"
            asyncio.get_event_loop().run_in_executor(None, cv2.imwrite, path, frame)
        event = {
            "ts": time.time(), "idx": self.frame_idx,
            "detections": [{"label": d.label, "dist": d.distance_m, "zone": d.zone}
                           for d in detections],
            "gesture": gesture.name, "action": cmd.action,
            "speed": cmd.speed, "reason": cmd.reason,
        }
        with open(self.events_path, "a") as f:
            f.write(json.dumps(event) + "\n")
        self.frame_idx += 1

session_logger = SessionLogger()
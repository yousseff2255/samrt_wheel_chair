import asyncio
import time
from dataclasses import dataclass, field
from typing import Optional
import numpy as np

@dataclass
class Detection:
    label: str
    confidence: float
    bbox: tuple[int, int, int, int]   # x1, y1, x2, y2
    distance_m: float
    zone: str                          # "left" | "center" | "right"

@dataclass
class GestureResult:
    name: str = "none"                 # "stop" | "go" | "left" | "right" | "speed_up" | "slow_down" | "none"
    confidence: float = 0.0
    landmarks: list = field(default_factory=list)
    hand_bbox: Optional[tuple[int,int,int,int]] = None

@dataclass
class Command:
    action: str = "stop"               # "forward" | "backward" | "left" | "right" | "stop"
    speed: float = 0.0                 # 0.0 to 1.0
    reason: str = "init"
    timestamp: float = 0.0

class AppState:
    def __init__(self):
        self.latest_frame: Optional[np.ndarray] = None
        self.latest_frame_ts: float = 0.0
        self.detections: list[Detection] = []
        self.gesture: GestureResult = GestureResult()
        self.last_command: Command = Command()
        self.mode: str = "autonomous"  # "autonomous" | "manual" | "gesture_only" | "stopped"
        self.manual_input: Optional[Command] = None
        self.metrics: dict = {
            "fps": 0.0, "inference_ms": 0.0,
            "yolo_ms": 0.0, "gesture_ms": 0.0,
            "pi_to_gcp_ms": 0.0,
        }
        self.lock = asyncio.Lock()

state = AppState()
import time
import numpy as np
import mediapipe as mp
from app.config import settings
from app.state import GestureResult

mp_hands = mp.solutions.hands

# Landmark IDs we care about
TIPS = [4, 8, 12, 16, 20]      # thumb, index, middle, ring, pinky tips
PIPS = [3, 6, 10, 14, 18]      # joints below each tip

class GestureDetector:
    def __init__(self):
        self.hands = mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=1,
            min_detection_confidence=0.6,
            min_tracking_confidence=0.5,
        )
        self._history: list[str] = []
    
    def detect(self, frame: np.ndarray) -> tuple[GestureResult, float]:
        t0 = time.perf_counter()
        rgb = frame[:, :, ::-1]  # BGR -> RGB
        result = self.hands.process(rgb)
        elapsed_ms = (time.perf_counter() - t0) * 1000
        
        if not result.multi_hand_landmarks:
            self._history.clear()
            return GestureResult(), elapsed_ms
        
        lm = result.multi_hand_landmarks[0].landmark
        h, w = frame.shape[:2]
        pts = [(int(p.x * w), int(p.y * h)) for p in lm]
        
        # Hand bbox + size filter
        xs, ys = zip(*pts)
        x1, y1, x2, y2 = min(xs), min(ys), max(xs), max(ys)
        if (x2 - x1) < settings.hand_min_size_px:
            return GestureResult(), elapsed_ms
        
        fingers = self._count_fingers(pts, result.multi_handedness[0])
        name = self._classify(fingers)
        
        # Require gesture to persist N frames
        self._history.append(name)
        if len(self._history) > settings.gesture_hold_frames:
            self._history.pop(0)
        stable = name if self._history.count(name) == len(self._history) else "none"
        
        return GestureResult(
            name=stable,
            confidence=1.0 if stable != "none" else 0.0,
            landmarks=pts,
            hand_bbox=(x1, y1, x2, y2),
        ), elapsed_ms
    
    def _count_fingers(self, pts, handedness) -> list[int]:
        """Returns [thumb, index, middle, ring, pinky] each 0 or 1."""
        f = []
        # Thumb: compare x of tip vs joint (depends on left/right hand)
        is_right = handedness.classification[0].label == "Right"
        if is_right:
            f.append(1 if pts[TIPS[0]][0] > pts[PIPS[0]][0] else 0)
        else:
            f.append(1 if pts[TIPS[0]][0] < pts[PIPS[0]][0] else 0)
        # Other fingers: tip above PIP joint = extended
        for tip, pip in zip(TIPS[1:], PIPS[1:]):
            f.append(1 if pts[tip][1] < pts[pip][1] else 0)
        return f
    
    def _classify(self, f: list[int]) -> str:
        thumb, index, middle, ring, pinky = f
        total = sum(f)
        if total == 5:                       return "stop"        # open palm
        if total == 0:                       return "go"          # fist
        if f == [0,1,0,0,0]:                 return "left"        # index only
        if f == [0,1,1,0,0]:                 return "right"       # peace
        if f == [1,0,0,0,0]:                 return "speed_up"    # thumbs up-ish
        if f == [0,0,0,0,1]:                 return "slow_down"   # pinky
        return "none"
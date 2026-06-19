import time
from app.config import settings
from app.state import Command, Detection, GestureResult

def _hand_overlaps_person(hand_bbox, person_bbox) -> bool:
    if hand_bbox is None or person_bbox is None: return False
    hx1, hy1, hx2, hy2 = hand_bbox
    px1, py1, px2, py2 = person_bbox
    return not (hx2 < px1 or hx1 > px2 or hy2 < py1 or hy1 > py2)

def decide(detections: list[Detection],
           gesture: GestureResult,
           mode: str,
           manual: Command | None) -> Command:
    
    now = time.time()
    
    if mode == "stopped":
        return Command("stop", 0.0, "mode=stopped", now)
    
    # --- Driver suppression: if gesturing user is detected as a "person"
    # obstacle, ignore that specific person ---
    active_detections = detections
    if gesture.name != "none" and gesture.hand_bbox is not None:
        active_detections = [
            d for d in detections
            if not (d.label == "person" and _hand_overlaps_person(gesture.hand_bbox, d.bbox))
        ]
    
    # --- Priority 1: obstacle in center, close => STOP ---
    center_close = [d for d in active_detections
                    if d.zone == "center" and d.distance_m < settings.stop_distance_m]
    if center_close:
        d = min(center_close, key=lambda x: x.distance_m)
        return Command("stop", 0.0,
                       f"obstacle: {d.label} {d.distance_m:.2f}m center", now)
    
    # --- Priority 2: side avoidance ---
    left_close = any(d.distance_m < settings.slow_distance_m and d.zone == "left"
                     for d in active_detections)
    right_close = any(d.distance_m < settings.slow_distance_m and d.zone == "right"
                      for d in active_detections)
    
    # --- Priority 3: mode-specific behavior ---
    if mode == "manual":
        if manual is None or (now - manual.timestamp) * 1000 > settings.command_timeout_ms:
            return Command("stop", 0.0, "manual timeout", now)
        cmd = Command(manual.action, manual.speed, "manual", now)
    elif mode == "gesture_only":
        cmd = _gesture_to_command(gesture, now)
    else:  # autonomous
        cmd = _gesture_to_command(gesture, now)
        if cmd.action == "stop" and gesture.name == "none":
            # No gesture, no obstacle => idle stop (safest default)
            cmd = Command("stop", 0.0, "no input", now)
    
    # --- Apply soft side avoidance: steer away from close side obstacle ---
    if cmd.action == "forward":
        if left_close and not right_close:
            cmd = Command("right", min(cmd.speed, 0.4), f"avoid left + {cmd.reason}", now)
        elif right_close and not left_close:
            cmd = Command("left", min(cmd.speed, 0.4), f"avoid right + {cmd.reason}", now)
    
    return cmd

def _gesture_to_command(g: GestureResult, now: float) -> Command:
    mapping = {
        "stop":      ("stop",     0.0),
        "go":        ("forward",  0.5),
        "left":      ("left",     0.4),
        "right":     ("right",    0.4),
        "speed_up":  ("forward",  0.8),
        "slow_down": ("forward",  0.25),
    }
    action, speed = mapping.get(g.name, ("stop", 0.0))
    return Command(action, speed, f"gesture: {g.name}", now)
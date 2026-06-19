import cv2
from app.state import Detection, GestureResult, Command

def draw_overlay(frame, detections, gesture, command, metrics):
    out = frame.copy()
    h, w = out.shape[:2]
    
    # Zone lines
    margin = int(w * 0.3)
    cv2.line(out, (margin, 0), (margin, h), (80, 80, 80), 1)
    cv2.line(out, (w - margin, 0), (w - margin, h), (80, 80, 80), 1)
    
    # YOLO boxes
    for d in detections:
        x1, y1, x2, y2 = d.bbox
        color = (0, 0, 255) if d.zone == "center" else (0, 200, 0)
        cv2.rectangle(out, (x1, y1), (x2, y2), color, 2)
        label = f"{d.label} {d.distance_m:.2f}m"
        cv2.putText(out, label, (x1, max(15, y1 - 6)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 1)
    
    # MediaPipe landmarks
    for (x, y) in gesture.landmarks:
        cv2.circle(out, (x, y), 3, (255, 200, 0), -1)
    if gesture.hand_bbox:
        x1, y1, x2, y2 = gesture.hand_bbox
        cv2.rectangle(out, (x1, y1), (x2, y2), (255, 200, 0), 2)
    
    # HUD panel
    hud = [
        f"Gesture: {gesture.name} ({gesture.confidence:.2f})",
        f"Action: {command.action} @ {command.speed:.2f}",
        f"Reason: {command.reason}",
        f"FPS: {metrics.get('fps', 0):.1f}  YOLO: {metrics.get('yolo_ms', 0):.0f}ms  Hand: {metrics.get('gesture_ms', 0):.0f}ms",
    ]
    for i, line in enumerate(hud):
        cv2.putText(out, line, (10, 20 + i * 18),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    return out
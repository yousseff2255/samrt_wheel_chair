import time
import numpy as np
from ultralytics import YOLO
from app.config import settings
from app.state import Detection
from app.processors.distance import estimate_distance_m, zone_of

class YoloDetector:
    def __init__(self):
        self.model = YOLO(settings.yolo_model)
        # warm up
        dummy = np.zeros((settings.frame_height, settings.frame_width, 3), dtype=np.uint8)
        self.model.predict(dummy, device=settings.yolo_device, verbose=False)
    
    def detect(self, frame: np.ndarray) -> tuple[list[Detection], float]:
        t0 = time.perf_counter()
        results = self.model.predict(
            frame,
            conf=settings.yolo_conf,
            device=settings.yolo_device,
            classes=settings.yolo_classes,
            verbose=False,
        )[0]
        elapsed_ms = (time.perf_counter() - t0) * 1000
        
        detections = []
        names = results.names
        h, w = frame.shape[:2]
        for box in results.boxes:
            cls_id = int(box.cls[0])
            label = names[cls_id]
            conf = float(box.conf[0])
            x1, y1, x2, y2 = map(int, box.xyxy[0])
            bbox_h = y2 - y1
            x_center = (x1 + x2) // 2
            detections.append(Detection(
                label=label,
                confidence=conf,
                bbox=(x1, y1, x2, y2),
                distance_m=estimate_distance_m(label, bbox_h),
                zone=zone_of(x_center, w),
            ))
        return detections, elapsed_ms
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    
    # Processing
    target_fps: int = 12              # frames/sec to process
    frame_width: int = 640
    frame_height: int = 480
    
    # YOLO
    yolo_model: str = "yolov8n.pt"    # use yolov8s.pt if GPU is strong
    yolo_conf: float = 0.45
    yolo_classes: list[int] | None = None  # None = all COCO classes
    yolo_device: str = "cuda:0"       # use "cpu" if no GPU
    
    # Distance estimation (monocular, rough)
    focal_length_px: float = 600.0    # calibrate once with known object
    known_heights_m: dict = {         # real-world heights, meters
        "person": 1.7, "chair": 0.9, "bottle": 0.25,
        "cup": 0.1, "sports ball": 0.22, "backpack": 0.5,
        "book": 0.25, "cell phone": 0.15, "laptop": 0.3,
        "default": 0.4,
    }
    
    # Decision logic
    stop_distance_m: float = 0.6      # stop if closer than this
    slow_distance_m: float = 1.2      # slow down if closer than this
    center_zone_pct: float = 0.4      # middle 40% of frame is "center"
    
    # Gesture
    gesture_hold_frames: int = 3      # frames a gesture must persist
    hand_min_size_px: int = 80        # ignore tiny hands (background)
    
    # Safety
    command_timeout_ms: int = 500     # Pi stops if no command this long
    
    # Logging
    gcs_bucket: str = ""              # leave empty to disable
    log_to_disk: bool = True

    # Frame ingest
    max_frame_age_ms: int = 800        # ignore frames older than this
    api_key: str = "change-me-secret"  # simple shared-secret auth
    
settings = Settings()
from app.config import settings

def estimate_distance_m(label: str, bbox_height_px: int) -> float:
    if bbox_height_px <= 0:
        return 999.0
    h_real = settings.known_heights_m.get(label, settings.known_heights_m["default"])
    return (h_real * settings.focal_length_px) / bbox_height_px

def zone_of(x_center: int, frame_width: int) -> str:
    margin = (1 - settings.center_zone_pct) / 2
    left_edge = frame_width * margin
    right_edge = frame_width * (1 - margin)
    if x_center < left_edge: return "left"
    if x_center > right_edge: return "right"
    return "center"
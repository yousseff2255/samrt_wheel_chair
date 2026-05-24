// detection_model.dart
// Holds the data structure for what the server returns via WebSocket.
// The server sends JSON like:
// {
//   "gesture": "FORWARD",
//   "command": "F",
//   "fps": 15.2,
//   "detections": [
//     {"label": "chair", "distance_m": 1.2, "zone": "center"},
//     {"label": "person", "distance_m": 2.5, "zone": "left"}
//   ]
// }

class ObstacleDetection {
  final String label; // e.g. "chair", "person", "table"
  final double distanceMeters; // e.g. 1.2 (meters away)
  final String zone; // "center", "left", or "right"

  ObstacleDetection({
    required this.label,
    required this.distanceMeters,
    required this.zone,
  });

  // Converts one item from the "detections" array in the JSON
  factory ObstacleDetection.fromMap(Map<String, dynamic> map) {
    return ObstacleDetection(
      label: (map['label'] as String?) ?? 'unknown',
      distanceMeters: ((map['distance_m'] as num?) ?? 0.0).toDouble(),
      zone: (map['zone'] as String?) ?? 'unknown',
    );
  }

  // Returns true if obstacle is dangerously close (within 1 meter in center)
  bool get isDangerous => distanceMeters < 1.0 && zone == 'center';
}

class DetectionResult {
  final String
      gesture; // "FORWARD", "BACKWARD", "LEFT", "RIGHT", "STOP", "NONE"
  final String command; // Single char: "F", "B", "L", "R", "S"
  final double fps; // Frames per second the server is processing
  final List<ObstacleDetection> detections; // List of detected obstacles

  DetectionResult({
    required this.gesture,
    required this.command,
    required this.fps,
    required this.detections,
  });

  // Converts the full WebSocket JSON message into a DetectionResult object
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    // Parse the detections array — safely handle if it's null or missing
    final rawDetections = json['detections'] as List<dynamic>? ?? [];
    final detections = rawDetections
        .map((d) => ObstacleDetection.fromMap(d as Map<String, dynamic>))
        .toList();

    return DetectionResult(
      gesture: (json['gesture'] as String?) ?? 'NONE',
      command: (json['command'] as String?) ?? 'S',
      fps: ((json['fps'] as num?) ?? 0.0).toDouble(),
      detections: detections,
    );
  }

  // Default empty state — used before WebSocket connects
  factory DetectionResult.empty() {
    return DetectionResult(
      gesture: 'NONE',
      command: 'S',
      fps: 0.0,
      detections: [],
    );
  }

  // Returns true if any obstacle is in danger zone
  bool get hasDangerousObstacle => detections.any((d) => d.isDangerous);

  // Maps gesture string to a display-friendly icon
  String get gestureIcon {
    switch (gesture) {
      case 'FORWARD':
        return '👆';
      case 'BACKWARD':
        return '👇';
      case 'LEFT':
        return '👈';
      case 'RIGHT':
        return '👉';
      case 'STOP':
        return '✋';
      default:
        return '❓';
    }
  }

  // Maps gesture to a color description (used for UI coloring)
  bool get isMovingGesture =>
      gesture == 'FORWARD' ||
      gesture == 'BACKWARD' ||
      gesture == 'LEFT' ||
      gesture == 'RIGHT';
}

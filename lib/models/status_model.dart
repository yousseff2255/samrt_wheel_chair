class StatusModel {
  final bool isMoving;
  final String direction;
  final double obstacleDistance;   // In centimeters
  final int batteryLevel;          // 0-100 %

  StatusModel({
    required this.isMoving,
    required this.direction,
    required this.obstacleDistance,
    required this.batteryLevel,
  });

  factory StatusModel.fromMap(Map<dynamic, dynamic> map) {
    return StatusModel(
      isMoving: (map['is_moving'] as bool?) ?? false,
      direction: (map['direction'] as String?) ?? 'none',
      // 'as num?' handles both int and double safely, then converts to double
      obstacleDistance: ((map['obstacle_distance'] as num?) ?? 999).toDouble(),
      batteryLevel: (map['battery_level'] as num?)?.toInt() ?? 100,
    );
  }

  factory StatusModel.empty() {
    return StatusModel(
      isMoving: false,
      direction: 'none',
      obstacleDistance: 999,   // 999 = "no obstacle detected"
      batteryLevel: 100,
    );
  }

  // Computed safety state flags used by the UI
  bool get isObstacleWarning => obstacleDistance < 50;    // Level 1: warning zone
  bool get isObstacleDanger => obstacleDistance < 15;     // Level 2: hard stop zone
}
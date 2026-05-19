class AlertModel {
  final bool fallDetected;
  final bool collisionWarning;
  final bool vitalsAbnormal;

  AlertModel({
    required this.fallDetected,
    required this.collisionWarning,
    required this.vitalsAbnormal,
  });

  factory AlertModel.fromMap(Map<dynamic, dynamic> map) {
    return AlertModel(
      fallDetected: (map['fall_detected'] as bool?) ?? false,
      collisionWarning: (map['collision_warning'] as bool?) ?? false,
      vitalsAbnormal: (map['vitals_abnormal'] as bool?) ?? false,
    );
  }

  factory AlertModel.empty() {
    return AlertModel(
      fallDetected: false,
      collisionWarning: false,
      vitalsAbnormal: false,
    );
  }

  // True if ANY alert is currently active
  bool get hasAnyAlert => fallDetected || collisionWarning || vitalsAbnormal;
}
// A model is just a class that defines what a piece of data looks like.
// This makes working with Firebase data safe and organized.

class VitalsModel {
  final int heartRate;   // Beats per minute
  final int spo2;        // Blood oxygen saturation (%)
  final int timestamp;   // Unix timestamp of last reading

  VitalsModel({
    required this.heartRate,
    required this.spo2,
    required this.timestamp,
  });

  // Factory constructor: takes raw Firebase data (a Map) and creates a VitalsModel.
  // The 'as num?' safely handles cases where Firebase returns int OR double.
  factory VitalsModel.fromMap(Map<dynamic, dynamic> map) {
    return VitalsModel(
      heartRate: (map['heart_rate'] as num?)?.toInt() ?? 0,
      spo2: (map['spo2'] as num?)?.toInt() ?? 0,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  // Returns default zero values before Firebase responds
  factory VitalsModel.empty() {
    return VitalsModel(heartRate: 0, spo2: 0, timestamp: 0);
  }

  // Computed properties — returns true if the value is outside safe range
  bool get isHeartRateAbnormal => heartRate > 100 || (heartRate < 50 && heartRate > 0);
  bool get isSpO2Abnormal => spo2 < 95 && spo2 > 0;
  bool get hasAnyAbnormality => isHeartRateAbnormal || isSpO2Abnormal;
}
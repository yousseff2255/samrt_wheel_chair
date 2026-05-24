import 'package:firebase_database/firebase_database.dart';
import '../models/vitals_model.dart';
import '../models/status_model.dart';
import '../models/alert_model.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ── READ STREAMS ──────────────────────────────────────────────────────────

  Stream<VitalsModel> get vitalsStream {
    return _db.child('vitals').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return VitalsModel.empty();
      return VitalsModel.fromMap(data as Map<dynamic, dynamic>);
    });
  }

  Stream<StatusModel> get statusStream {
    return _db.child('status').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return StatusModel.empty();
      return StatusModel.fromMap(data as Map<dynamic, dynamic>);
    });
  }

  Stream<AlertModel> get alertStream {
    return _db.child('alerts').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return AlertModel.empty();
      return AlertModel.fromMap(data as Map<dynamic, dynamic>);
    });
  }

  // ── GESTURE STREAM ────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> get gestureStream {
    return _db.child('current_gesture').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return {};
      return Map<String, dynamic>.from(data as Map);
    });
  }

  String? mapGestureCommand(String? code) {
    const map = {
      'F': 'forward',
      'B': 'backward',
      'L': 'left',
      'R': 'right',
      'S': 'stop',
      'NONE': null,
    };
    return map[code?.toUpperCase()];
  }

  // ── WRITE COMMANDS ────────────────────────────────────────────────────────

  Future<void> sendCommand(String command) async {
    await _db.child('commands').update({
      'override_active': true,
      'emergency_stop': false,
      'command': command,
    });
  }

  Future<void> emergencyStop() async {
    await _db.child('commands').update({
      'override_active': true,
      'emergency_stop': true,
      'command': 'stop',
    });
  }

  Future<void> releaseOverride() async {
    await _db.child('commands').update({
      'override_active': false,
      'emergency_stop': false,
      'command': 'none',
    });
  }
}

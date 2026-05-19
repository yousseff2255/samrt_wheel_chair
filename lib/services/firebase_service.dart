import 'package:firebase_database/firebase_database.dart';
import '../models/vitals_model.dart';
import '../models/status_model.dart';
import '../models/alert_model.dart';

// Singleton: this class has only ONE instance throughout the whole app.
// This avoids creating multiple Firebase connections by accident.
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Root reference to your Firebase database
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ── READ STREAMS ─────────────────────────────────────────────────────────
  // A Stream is like a live pipe of data.
  // Every time Firebase data changes, the stream emits a new value.
  // The UI "listens" to these streams and rebuilds automatically.

  Stream<VitalsModel> get vitalsStream {
    // .onValue fires immediately with current data, then again on every change
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

  // ── WRITE COMMANDS (App → Firebase → Pi) ─────────────────────────────────

  // Sends a directional command to Firebase.
  // The Pi is listening and will execute this command via UART to the PIC.
  Future<void> sendCommand(String command) async {
    await _db.child('commands').update({
      'override_active': true,
      'emergency_stop': false,
      'command': command,   // 'forward', 'backward', 'left', 'right', 'stop'
    });
  }

  // Highest-priority command. Sets emergency_stop: true.
  // The Pi firmware should treat this with immediate priority.
  Future<void> emergencyStop() async {
    await _db.child('commands').update({
      'override_active': true,
      'emergency_stop': true,
      'command': 'stop',
    });
  }

  // Releases manual control back to gesture mode
  Future<void> releaseOverride() async {
    await _db.child('commands').update({
      'override_active': false,
      'emergency_stop': false,
      'command': 'none',
    });
  }
}
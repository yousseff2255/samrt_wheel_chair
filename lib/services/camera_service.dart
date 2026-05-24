// camera_service.dart
// Handles two connections to the model server:
// 1. HTTP polling every 500ms for the annotated JPEG image (/snapshot)
// 2. WebSocket connection for live JSON detection data (/ws/dashboard)

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/detection_model.dart';

class CameraService {
  // Server addresses — change these if the server IP changes
  static const String _baseUrl = 'http://34.18.190.112:8000';
  static const String _snapshotUrl = '$_baseUrl/snapshot';
  static const String _wsUrl = 'ws://34.18.190.112:8000/ws/dashboard';
  static const String _healthUrl = '$_baseUrl/health';

  // WebSocket channel — the persistent connection to the server
  WebSocketChannel? _channel;

  // Stream controllers — these are "broadcast stations" that emit data
  // to whoever is listening (in this case, the UI)
  final _imageController = StreamController<Uint8List>.broadcast();
  final _detectionController = StreamController<DetectionResult>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Public streams — the UI subscribes to these
  Stream<Uint8List> get imageStream => _imageController.stream;
  Stream<DetectionResult> get detectionStream => _detectionController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isRunning = false;
  Timer? _imageTimer;

  // ── START ────────────────────────────────────────────────────────────────
  // Call this when the Camera tab is opened
  void start() {
    if (_isRunning) return; // Don't start twice
    _isRunning = true;
    _connectWebSocket();
    _startImagePolling();
  }

  // ── STOP ─────────────────────────────────────────────────────────────────
  // Call this when the Camera tab is closed or app goes to background
  void stop() {
    _isRunning = false;
    _imageTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  // ── WEBSOCKET CONNECTION ─────────────────────────────────────────────────
  // Connects to ws://34.18.190.112:8000/ws/dashboard
  // Receives JSON detection results in real time
  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _connectionController.add(true); // Tell UI we're connected

      // Listen for incoming messages from the server
      _channel!.stream.listen(
        (message) {
          // message is a JSON string — parse it
          try {
            final json = jsonDecode(message as String) as Map<String, dynamic>;
            final result = DetectionResult.fromJson(json);
            // Push the parsed result to the UI stream
            if (!_detectionController.isClosed) {
              _detectionController.add(result);
            }
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _connectionController.add(false);
          // Auto-reconnect after 3 seconds if still supposed to be running
          if (_isRunning) {
            Future.delayed(const Duration(seconds: 3), _connectWebSocket);
          }
        },
        onDone: () {
          _connectionController.add(false);
          if (_isRunning) {
            Future.delayed(const Duration(seconds: 3), _connectWebSocket);
          }
        },
      );
    } catch (e) {
      debugPrint('WebSocket connect failed: $e');
      _connectionController.add(false);
      if (_isRunning) {
        Future.delayed(const Duration(seconds: 3), _connectWebSocket);
      }
    }
  }

  // ── IMAGE POLLING ────────────────────────────────────────────────────────
  // Fetches /snapshot every 500ms
  // Returns a JPEG image with gesture overlay + YOLO bounding boxes drawn on it
  void _startImagePolling() {
    _imageTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _fetchSnapshot(),
    );
    _fetchSnapshot(); // Fetch immediately, don't wait 500ms for first image
  }

  Future<void> _fetchSnapshot() async {
    try {
      final response = await http
          .get(Uri.parse(_snapshotUrl))
          .timeout(const Duration(seconds: 2)); // Don't hang if server is slow

      if (response.statusCode == 200) {
        // response.bodyBytes is the raw JPEG data
        if (!_imageController.isClosed) {
          _imageController.add(response.bodyBytes);
        }
      }
    } catch (e) {
      // Silently ignore — the image just won't update this cycle
      debugPrint('Snapshot fetch error: $e');
    }
  }

  // ── HEALTH CHECK ─────────────────────────────────────────────────────────
  // Call this to check if the server is reachable before connecting
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse(_healthUrl))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ── CLEANUP ──────────────────────────────────────────────────────────────
  void dispose() {
    stop();
    _imageController.close();
    _detectionController.close();
    _connectionController.close();
  }
}

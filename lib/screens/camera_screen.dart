// camera_screen.dart
// The Camera Control tab — shows live annotated image + detection results

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../models/detection_model.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final CameraService _cameraService = CameraService();

  Uint8List? _currentImage;
  DetectionResult _detection = DetectionResult.empty();
  bool _isConnected = false;
  bool _isServerReachable = false;
  bool _isCheckingServer = true;

  late StreamSubscription _imageSub;
  late StreamSubscription _detectionSub;
  late StreamSubscription _connectionSub;

  @override
  void initState() {
    super.initState();
    _checkAndConnect();
  }

  Future<void> _checkAndConnect() async {
    setState(() => _isCheckingServer = true);
    final reachable = await _cameraService.checkHealth();
    setState(() {
      _isServerReachable = reachable;
      _isCheckingServer = false;
    });

    if (reachable) {
      _startListening();
      _cameraService.start();
    }
  }

  void _startListening() {
    _imageSub = _cameraService.imageStream.listen((imageBytes) {
      if (mounted) setState(() => _currentImage = imageBytes);
    });

    _detectionSub = _cameraService.detectionStream.listen((result) {
      if (mounted) setState(() => _detection = result);
    });

    _connectionSub = _cameraService.connectionStream.listen((connected) {
      if (mounted) setState(() => _isConnected = connected);
    });
  }

  @override
  void dispose() {
    _imageSub.cancel();
    _detectionSub.cancel();
    _connectionSub.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        if (_isCheckingServer)
          _buildCheckingView()
        else if (!_isServerReachable)
          _buildServerOfflineView()
        else ...[
          _buildCameraFeed(),
          const SizedBox(height: 16),
          _buildGestureCard(),
          const SizedBox(height: 16),
          _buildObstacleList(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Camera AI Control',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Live gesture & obstacle detection',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isConnected
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isConnected ? Colors.green : Colors.red,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isConnected ? 'Live' : 'Offline',
                style: TextStyle(
                  color: _isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckingView() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF1565C0)),
            SizedBox(height: 16),
            Text('Connecting to AI server...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildServerOfflineView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 56, color: Colors.red),
          const SizedBox(height: 16),
          const Text('AI Server Unreachable',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red)),
          const SizedBox(height: 8),
          Text(
            'Cannot connect to 34.18.190.112:8000\n'
            'Make sure the Raspberry Pi server is running.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _checkAndConnect,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Live Feed',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_detection.fps.toStringAsFixed(1)} FPS',
                style: const TextStyle(
                    color: Colors.green, fontSize: 11, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 260,
            color: Colors.black,
            child: _currentImage != null
                ? Image.memory(
                    _currentImage!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white38),
                        SizedBox(height: 12),
                        Text('Waiting for first frame...',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Image includes gesture landmarks + YOLO bounding boxes from server',
          style: TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildGestureCard() {
    final Color gestureColor = _detection.isMovingGesture
        ? const Color(0xFF1565C0)
        : _detection.gesture == 'STOP'
            ? Colors.orange
            : Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gestureColor.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gestureColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Gesture Reference',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _buildGestureRef('👆 Open hand (1 hand)', 'FORWARD'),
          _buildGestureRef('👇 Fist (1 hand)', 'BACKWARD'),
          _buildGestureRef('👐 Both hands open', 'LEFT'),
          _buildGestureRef('🤜 Both fists', 'RIGHT'),
          _buildGestureRef('🚫 No hands visible', 'STOP'),
        ],
      ),
    );
  }

  Widget _buildGestureRef(String gesture, String command) {
    final bool isActive = _detection.gesture == command;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(gesture,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1565C0) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(command,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.grey,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildObstacleList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Detected Obstacles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Spacer(),
            if (_detection.hasDangerousObstacle)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('DANGER ZONE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_detection.detections.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 10),
                Text('No obstacles detected',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        else
          ...(_detection.detections.map((obs) => _buildObstacleTile(obs))),
      ],
    );
  }

  Widget _buildObstacleTile(ObstacleDetection obs) {
    final Color tileColor = obs.isDangerous ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tileColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tileColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tileColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              obs.isDangerous
                  ? Icons.warning_rounded
                  : Icons.directions_walk_rounded,
              color: tileColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obs.label[0].toUpperCase() + obs.label.substring(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: tileColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Zone: ${obs.zone.toUpperCase()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${obs.distanceMeters.toStringAsFixed(1)}m',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: tileColor,
                ),
              ),
              Text(
                obs.isDangerous ? 'TOO CLOSE' : 'ahead',
                style: TextStyle(
                  fontSize: 10,
                  color: tileColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

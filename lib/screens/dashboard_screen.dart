import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../models/vitals_model.dart';
import '../models/status_model.dart';
import '../models/alert_model.dart';
import '../widgets/vital_card.dart';
import '../widgets/status_card.dart';
import '../widgets/control_pad.dart';
import '../widgets/alert_banner.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebase = FirebaseService();

  // Current data state
  VitalsModel _vitals = VitalsModel.empty();
  StatusModel _status = StatusModel.empty();
  AlertModel _alerts = AlertModel.empty();
  bool _isLoading = true;
  int _selectedTab = 0;

  // Track previous alert states to detect NEW alerts (not repeated triggers)
  bool _prevFall = false;
  bool _prevVitalsAbnormal = false;
  bool _prevCollision = false;

  // Stream subscriptions — must cancel these when screen is disposed
  // to prevent memory leaks
  late StreamSubscription _vitalsSubscription;
  late StreamSubscription _statusSubscription;
  late StreamSubscription _alertSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // ── Vitals stream ─────────────────────────────────────────────────────
    _vitalsSubscription = _firebase.vitalsStream.listen((vitals) {
      // Check if vitals just BECAME abnormal (wasn't abnormal before)
      if (vitals.hasAnyAbnormality && !_prevVitalsAbnormal) {
        _onVitalsAlert(vitals);
      }
      _prevVitalsAbnormal = vitals.hasAnyAbnormality;

      setState(() {
        _vitals = vitals;
        _isLoading = false; // Hide loading spinner once first data arrives
      });
    });

    // ── Status stream ─────────────────────────────────────────────────────
    _statusSubscription = _firebase.statusStream.listen((status) {
      // Check if obstacle warning just triggered
      if (status.isObstacleWarning && !_prevCollision) {
        NotificationService.showWarningAlert(
          title: '⚠️ Obstacle Detected',
          body:
              'Object within ${status.obstacleDistance.toStringAsFixed(0)}cm of wheelchair',
        );
      }
      _prevCollision = status.isObstacleWarning;
      setState(() => _status = status);
    });

    // ── Alert stream ──────────────────────────────────────────────────────
    _alertSubscription = _firebase.alertStream.listen((alerts) {
      // Fall: just became true
      if (alerts.fallDetected && !_prevFall) {
        _onFallAlert();
      }
      _prevFall = alerts.fallDetected;
      setState(() => _alerts = alerts);
    });
  }

  void _onFallAlert() {
    // 1. Send push notification (works even if app is in background)
    NotificationService.showEmergencyAlert(
      title: '🚨 FALL DETECTED',
      body: 'The wheelchair has tipped over. Check on the user immediately!',
    );
    // 2. Show in-app dialog (if app is open)
    _showAlertDialog(
      '🚨 Fall Detected',
      'The wheelchair has tipped over.\nPlease check on the user immediately.',
      Colors.red,
    );
  }

  void _onVitalsAlert(VitalsModel vitals) {
    String message = '';
    if (vitals.isHeartRateAbnormal) {
      message += 'Heart rate: ${vitals.heartRate} BPM is outside safe range.\n';
    }
    if (vitals.isSpO2Abnormal) {
      message += 'SpO2: ${vitals.spo2}% is dangerously low.';
    }
    NotificationService.showEmergencyAlert(
      title: '❤️ Abnormal Vitals',
      body: message,
    );
    _showAlertDialog('❤️ Abnormal Vitals', message, Colors.orange);
  }

  void _showAlertDialog(String title, String message, Color color) {
    // barrierDismissible: false forces user to read and acknowledge
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: TextStyle(color: color, fontSize: 18)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Acknowledged',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Cancel all Firebase listeners when the screen is removed from memory.
  // Without this, the app would continue listening even after being closed.
  @override
  void dispose() {
    _vitalsSubscription.cancel();
    _statusSubscription.cancel();
    _alertSubscription.cancel();
    super.dispose();
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingView() : _buildTabContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Row(
        children: [
          Icon(Icons.accessible_forward_rounded, size: 26),
          SizedBox(width: 10),
          Text('Smart Wheelchair',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        // Pulsing alert icon in top bar when alerts are active
        if (_alerts.hasAnyAlert)
          IconButton(
            icon: const Icon(Icons.notification_important_rounded,
                color: Colors.yellow),
            onPressed: () => setState(() => _selectedTab = 2),
            tooltip: 'View Alerts',
          ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF1565C0)),
          SizedBox(height: 16),
          Text('Connecting to wheelchair...',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text('Make sure Firebase is connected',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildControlsTab();
      case 2:
        return _buildAlertsTab();
      default:
        return _buildDashboardTab();
    }
  }

  // ── TAB 0: DASHBOARD ────────────────────────────────────────────────────

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert banner — only visible when alerts are active
          if (_alerts.hasAnyAlert) ...[
            AlertBanner(alerts: _alerts),
            const SizedBox(height: 16),
          ],

          const Text('Live Vitals',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),

          // Two vital cards side by side
          Row(
            children: [
              Expanded(
                child: VitalCard(
                  label: 'Heart Rate',
                  value: '${_vitals.heartRate}',
                  unit: 'BPM',
                  icon: Icons.favorite_rounded,
                  isAbnormal: _vitals.isHeartRateAbnormal,
                  normalRange: '50–100',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VitalCard(
                  label: 'SpO2',
                  value: '${_vitals.spo2}',
                  unit: '%',
                  icon: Icons.air_rounded,
                  isAbnormal: _vitals.isSpO2Abnormal,
                  normalRange: '≥95%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text('Wheelchair Status',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),
          StatusCard(status: _status),
          const SizedBox(height: 20),

          // Quick emergency stop accessible from dashboard
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.stop_circle_rounded,
                  color: Colors.white, size: 26),
              label: const Text('EMERGENCY STOP',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              onPressed: () async {
                await _firebase.emergencyStop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency stop sent to wheelchair'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('Sends immediate stop command via Firebase → Pi → PIC',
                style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  // ── TAB 1: CONTROLS ─────────────────────────────────────────────────────

  Widget _buildControlsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Manual Controls',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'Override gesture control and drive manually from the app.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ControlPad(
            onCommand: (command) async {
              await _firebase.sendCommand(command);
            },
            onEmergencyStop: () async {
              await _firebase.emergencyStop();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency stop sent!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            onReleaseOverride: () async {
              await _firebase.releaseOverride();
            },
          ),
        ],
      ),
    );
  }

  // ── TAB 2: ALERTS ───────────────────────────────────────────────────────

  Widget _buildAlertsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Safety Alerts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAlertTile(
            title: 'Fall Detection',
            subtitle: 'MPU6050 tilt exceeds safe threshold',
            isActive: _alerts.fallDetected,
            icon: Icons.personal_injury_rounded,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildAlertTile(
            title: 'Collision Warning',
            subtitle: 'Obstacle within 50cm (HC-SR04)',
            isActive: _alerts.collisionWarning,
            icon: Icons.warning_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildAlertTile(
            title: 'Abnormal Vitals',
            subtitle: 'Heart rate or SpO2 out of normal range',
            isActive: _alerts.vitalsAbnormal,
            icon: Icons.favorite_border_rounded,
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 24),
          if (!_alerts.hasAnyAlert)
            Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 72, color: Colors.green[400]),
                  const SizedBox(height: 12),
                  const Text('All systems normal',
                      style: TextStyle(color: Colors.green, fontSize: 17)),
                  const SizedBox(height: 4),
                  const Text('No active alerts',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertTile({
    required String title,
    required String subtitle,
    required bool isActive,
    required IconData icon,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? color.withOpacity(0.7) : Colors.grey.shade200,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? color : Colors.grey, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isActive ? color : Colors.black87)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'ACTIVE' : 'OK',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAVIGATION BAR ────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (index) => setState(() => _selectedTab = index),
      selectedItemColor: const Color(0xFF1565C0),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed, // Required for 4+ tabs
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.gamepad_rounded),
          label: 'Controls',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: _alerts.hasAnyAlert,
            label: const Text('!'),
            child: const Icon(Icons.notifications_rounded),
          ),
          label: 'Alerts',
        ),
      ],
    );
  }
}

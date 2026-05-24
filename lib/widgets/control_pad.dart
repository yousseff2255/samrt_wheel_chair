import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/voice_service.dart';
import '../screens/camera_screen.dart';

// ── Control mode enum ──────────────────────────────────────────────────────
enum ControlMode { none, manual, voice, camera }

class ControlPad extends StatefulWidget {
  final Function(String) onCommand;
  final VoidCallback onEmergencyStop;
  final VoidCallback onReleaseOverride;

  const ControlPad({
    super.key,
    required this.onCommand,
    required this.onEmergencyStop,
    required this.onReleaseOverride,
  });

  @override
  State<ControlPad> createState() => _ControlPadState();
}

class _ControlPadState extends State<ControlPad>
    with SingleTickerProviderStateMixin {
  // ── Mode state ──────────────────────────────────────────────────────────
  ControlMode _activeMode = ControlMode.none;

  // ── Voice state ─────────────────────────────────────────────────────────
  final VoiceService _voice = VoiceService();
  bool _voiceReady = false;

  // Whether the mic button is currently being held down
  bool _isHolding = false;

  // The last recognized command — persists until user holds again
  // null  = no command yet
  // 'disabled' = command was received, button is locked until next hold
  String? _lastVoiceCommand;

  // Live transcript shown while holding
  String _voiceTranscript = '';

  // Pulse animation while mic is held
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Camera state ────────────────────────────────────────────────────────
  StreamSubscription? _gestureSub;
  String _cameraCommand = ''; // Current gesture command from Firebase

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initVoice();
  }

  Future<void> _initVoice() async {
    final ok = await _voice.initialize();
    if (mounted) setState(() => _voiceReady = ok);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voice.dispose();
    _gestureSub?.cancel();
    super.dispose();
  }

  // ── Mode switching ───────────────────────────────────────────────────────

  void _setMode(ControlMode newMode) {
    if (_activeMode == newMode) {
      _deactivate(_activeMode);
      setState(() => _activeMode = ControlMode.none);
      widget.onReleaseOverride();
      return;
    }

    _deactivate(_activeMode);

    setState(() {
      _activeMode = newMode;
      _lastVoiceCommand = null;
      _voiceTranscript = '';
      _cameraCommand = '';
      _isHolding = false;
    });

    if (newMode == ControlMode.camera) _startCameraMode();
  }

  void _deactivate(ControlMode mode) {
    switch (mode) {
      case ControlMode.manual:
        widget.onCommand('stop');
        widget.onReleaseOverride();
        break;

      case ControlMode.voice:
        if (_isHolding) _voice.stopListening();
        if (mounted) {
          setState(() {
            _isHolding = false;
            _voiceTranscript = '';
            _lastVoiceCommand = null;
          });
        }
        widget.onCommand('stop');
        widget.onReleaseOverride();
        break;

      case ControlMode.camera:
        _stopCameraMode();
        break;

      case ControlMode.none:
        break;
    }
  }

  // ── Camera mode ──────────────────────────────────────────────────────────

  void _startCameraMode() {
    _gestureSub = FirebaseService().gestureStream.listen((data) {
      final raw = data['command'] as String?;
      if (raw == null || raw.isEmpty || raw.toUpperCase() == 'NONE') return;

      final command =
          FirebaseService().mapGestureCommand(raw) ?? raw.toLowerCase();

      if (mounted) setState(() => _cameraCommand = command);
      widget.onCommand(command);
    });
  }

  void _stopCameraMode() {
    _gestureSub?.cancel();
    _gestureSub = null;
    if (mounted) setState(() => _cameraCommand = '');
    widget.onCommand('stop');
    widget.onReleaseOverride();
  }

  // ── Voice mode — hold to listen ──────────────────────────────────────────
  //
  // Behavior:
  //  - Hold mic button → start listening
  //  - Release OR command recognized → stop, send command, lock button
  //  - Button shows received command and is visually disabled
  //  - Hold again → clears last command, starts new session
  //

  Future<void> _onMicHoldStart() async {
    if (_activeMode != ControlMode.voice) return;
    if (!_voiceReady) return;

    // Clear previous command and start fresh session
    setState(() {
      _isHolding = true;
      _lastVoiceCommand = null;
      _voiceTranscript = 'Listening…';
    });

    await _voice.startListening(
      onCommand: (command) {
        // Command recognized → stop immediately, lock button
        _voice.stopListening();
        widget.onCommand(command);
        if (mounted) {
          setState(() {
            _lastVoiceCommand = command;
            _isHolding = false;
            _voiceTranscript = '';
          });
        }
      },
      onTranscript: (text) {
        // Only show transcript while still holding
        if (mounted && _isHolding) {
          setState(() => _voiceTranscript = text);
        }
      },
    );

    // Reached here if: user released before command recognized, OR timeout
    if (mounted && _isHolding) {
      setState(() {
        _isHolding = false;
        _voiceTranscript = '';
        // If no command was recognized, keep _lastVoiceCommand as null
      });
    }
  }

  void _onMicHoldEnd() {
    if (!_isHolding) return; // Already stopped by command recognition
    _voice.stopListening();
    if (mounted) {
      setState(() {
        _isHolding = false;
        _voiceTranscript = '';
      });
    }
  }

  // ── D-pad button ─────────────────────────────────────────────────────────

  Widget _buildDirectionButton({
    required IconData icon,
    required String command,
    Color color = const Color(0xFF1565C0),
  }) {
    return GestureDetector(
      onTapDown: (_) => widget.onCommand(command),
      onTapUp: (_) => widget.onCommand('stop'),
      onTapCancel: () => widget.onCommand('stop'),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  // ── Manual content ────────────────────────────────────────────────────────

  Widget _buildManualContent() {
    return Column(
      children: [
        _buildDirectionButton(
            icon: Icons.arrow_upward_rounded, command: 'forward'),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDirectionButton(
                icon: Icons.arrow_back_rounded, command: 'left'),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => widget.onCommand('stop'),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.stop_rounded,
                    color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 10),
            _buildDirectionButton(
                icon: Icons.arrow_forward_rounded, command: 'right'),
          ],
        ),
        const SizedBox(height: 10),
        _buildDirectionButton(
            icon: Icons.arrow_downward_rounded, command: 'backward'),
        const SizedBox(height: 8),
        Text(
          'Hold to move · Release to stop',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  // ── Voice content ─────────────────────────────────────────────────────────

  Widget _buildVoiceContent() {
    const Color activeColor = Color(0xFF00897B);

    // Button is locked (showing received command) when _lastVoiceCommand != null
    final bool isLocked = _lastVoiceCommand != null && !_isHolding;

    return Column(
      children: [
        // ── Received command badge ──────────────────────────────────────
        if (_lastVoiceCommand != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: activeColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.directions_run_rounded,
                    color: activeColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  _lastVoiceCommand!.toUpperCase(),
                  style: const TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── Mic button ──────────────────────────────────────────────────
        // Hold → listen. Release → stop.
        // Locked (greyed) after command received until held again.
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _isHolding ? _pulseAnim.value : 1.0,
              child: child,
            );
          },
          child: GestureDetector(
            onLongPressStart: (_) => _onMicHoldStart(),
            onLongPressEnd: (_) => _onMicHoldEnd(),
            onLongPressCancel: _onMicHoldEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !_voiceReady
                    ? Colors.grey.shade200
                    : isLocked
                        ? Colors.grey.shade200 // Locked after command
                        : _isHolding
                            ? activeColor // Active while holding
                            : activeColor.withOpacity(0.12),
                border: Border.all(
                  color: !_voiceReady
                      ? Colors.grey.shade300
                      : isLocked
                          ? Colors.grey.shade300
                          : activeColor,
                  width: 2.5,
                ),
                boxShadow: _isHolding
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _isHolding
                    ? Icons.mic_rounded
                    : isLocked
                        ? Icons.mic_off_rounded // Locked icon
                        : Icons.mic_none_rounded,
                color: !_voiceReady
                    ? Colors.grey.shade400
                    : isLocked
                        ? Colors.grey.shade400
                        : _isHolding
                            ? Colors.white
                            : activeColor,
                size: 42,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Status label ────────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Text(
            key: ValueKey('$_isHolding$_lastVoiceCommand$_voiceTranscript'),
            _voiceTranscript.isNotEmpty
                ? _voiceTranscript
                : !_voiceReady
                    ? 'Microphone unavailable'
                    : _isHolding
                        ? 'Listening — release to cancel'
                        : isLocked
                            ? 'Hold mic again to change command'
                            : 'Hold mic button to speak',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isHolding ? activeColor : Colors.grey.shade500,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // ── Stop movement button ─────────────────────────────────────────
        // Only shown when a non-stop command is active
        if (_lastVoiceCommand != null && _lastVoiceCommand != 'stop') ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              widget.onCommand('stop');
              setState(() => _lastVoiceCommand = 'stop');
            },
            icon: Icon(Icons.stop_circle_outlined,
                size: 18, color: Colors.red.shade400),
            label: Text('Stop Movement',
                style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ],
    );
  }

  // ── Camera content ────────────────────────────────────────────────────────
  //
  // Shows the live Firebase gesture command received from the Pi,
  // followed by the full CameraScreen (live feed + obstacle list).
  //

  Widget _buildCameraContent() {
    const Color cameraColor = Color(0xFF7B1FA2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Current Firebase gesture command display ──────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: cameraColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cameraColor.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Green dot = receiving commands, grey = waiting
                      color: _cameraCommand.isNotEmpty
                          ? Colors.green.shade400
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Camera Gesture',
                    style: TextStyle(
                      color: cameraColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // The command itself — large and prominent
              Text(
                _cameraCommand.isNotEmpty
                    ? _cameraCommand.toUpperCase()
                    : 'WAITING…',
                style: TextStyle(
                  color: _cameraCommand.isNotEmpty
                      ? cameraColor
                      : Colors.grey.shade400,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _cameraCommand.isNotEmpty
                    ? 'Command received from Firebase'
                    : 'No gesture detected yet',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Live camera feed + obstacle list ─────────────────────────
        const CameraScreen(),
      ],
    );
  }

  // ── Mode selector card ────────────────────────────────────────────────────

  Widget _buildModeCard({
    required ControlMode mode,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isActive = _activeMode == mode;

    return GestureDetector(
      onTap: () => _setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isActive ? Colors.white : Colors.grey.shade500,
                size: 26),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Mode selector ────────────────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Control Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only one mode can be active at a time',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeCard(
                        mode: ControlMode.manual,
                        icon: Icons.gamepad_rounded,
                        label: 'Manual\nControl',
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeCard(
                        mode: ControlMode.voice,
                        icon: Icons.mic_rounded,
                        label: 'Voice\nControl',
                        color: const Color(0xFF00897B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildModeCard(
                        mode: ControlMode.camera,
                        icon: Icons.remove_red_eye_rounded,
                        label: 'AI Camera\nControl',
                        color: const Color(0xFF7B1FA2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── Active mode content ──────────────────────────────────────────
        if (_activeMode == ControlMode.none)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                Icon(Icons.touch_app_rounded,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 14),
                Text(
                  'Select a control mode above',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          )
        else if (_activeMode == ControlMode.manual)
          _buildManualContent()
        else if (_activeMode == ControlMode.voice)
          _buildVoiceContent()
        else if (_activeMode == ControlMode.camera)
          _buildCameraContent(),

        const SizedBox(height: 32),

        // ── Emergency stop (always visible) ─────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.stop_circle_rounded,
                color: Colors.white, size: 28),
            label: const Text(
              'EMERGENCY STOP',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              _deactivate(_activeMode);
              setState(() => _activeMode = ControlMode.none);
              widget.onEmergencyStop();
            },
          ),
        ),
      ],
    );
  }
}

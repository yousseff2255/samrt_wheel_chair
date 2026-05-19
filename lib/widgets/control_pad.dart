import 'package:flutter/material.dart';

class ControlPad extends StatefulWidget {
  final Function(String) onCommand;     // Called when a direction is pressed
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

class _ControlPadState extends State<ControlPad> {
  bool _overrideActive = false;   // Tracks if manual control is on

  // Builds one directional arrow button
  // Uses GestureDetector so we can detect press-and-hold behavior:
  // onTapDown → start moving, onTapUp → send stop
  Widget _buildDirectionButton({
    required IconData icon,
    required String command,
    Color color = const Color(0xFF1565C0),
  }) {
    return GestureDetector(
      onTapDown: (_) {
        if (_overrideActive) widget.onCommand(command);
      },
      onTapUp: (_) {
        if (_overrideActive) widget.onCommand('stop');
      },
      onTapCancel: () {
        if (_overrideActive) widget.onCommand('stop');
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          // Greyed out when override is off — visual feedback that buttons are disabled
          color: _overrideActive ? color : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _overrideActive
              ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Override Toggle ──────────────────────────────────────────────
        Card(
          child: SwitchListTile(
            title: const Text('Manual Override Mode',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              _overrideActive
                  ? '⚠️ Gesture control disabled — you are driving'
                  : 'Enable to take manual control of the wheelchair',
              style: TextStyle(
                color: _overrideActive ? Colors.orange : Colors.grey,
              ),
            ),
            value: _overrideActive,
            activeThumbColor: const Color(0xFF1565C0),
            onChanged: (val) {
              setState(() => _overrideActive = val);
              if (!val) widget.onReleaseOverride();  // Release when turned off
            },
          ),
        ),
        const SizedBox(height: 32),

        // ── D-Pad ──────────────────────────────────────────────────────
        // Forward button (top)
        _buildDirectionButton(
            icon: Icons.arrow_upward_rounded, command: 'forward'),
        const SizedBox(height: 10),

        // Left / Stop / Right row (middle)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDirectionButton(
                icon: Icons.arrow_back_rounded, command: 'left'),
            const SizedBox(width: 10),
            // Center stop button (always active, even in gesture mode)
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

        // Backward button (bottom)
        _buildDirectionButton(
            icon: Icons.arrow_downward_rounded, command: 'backward'),

        const SizedBox(height: 12),
        const Text('Hold to move · Release to stop',
            style: TextStyle(color: Colors.grey, fontSize: 12)),

        const SizedBox(height: 32),

        // ── Emergency Stop ─────────────────────────────────────────────
        // This button is ALWAYS active regardless of override state
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
            label: const Text('EMERGENCY STOP',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            onPressed: widget.onEmergencyStop,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../models/alert_model.dart';

// A banner that appears at the top of the dashboard when any alert is active.
// Lists all currently active alerts.
class AlertBanner extends StatelessWidget {
  final AlertModel alerts;

  const AlertBanner({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Active Alerts',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          if (alerts.fallDetected)
            const Text('• 🚨 Fall detected — check on the user immediately',
                style: TextStyle(color: Colors.red)),
          if (alerts.collisionWarning)
            const Text('• ⚠️ Obstacle detected — collision warning',
                style: TextStyle(color: Colors.orange)),
          if (alerts.vitalsAbnormal)
            const Text('• ❤️ Abnormal vitals reading detected',
                style: TextStyle(color: Colors.deepOrange)),
        ],
      ),
    );
  }
}
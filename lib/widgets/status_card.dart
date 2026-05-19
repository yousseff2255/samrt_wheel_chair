import 'package:flutter/material.dart';
import '../models/status_model.dart';

class StatusCard extends StatelessWidget {
  final StatusModel status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: moving status + direction
          Row(
            children: [
              _buildStatusItem(
                icon: Icons.moving,
                label: 'Status',
                value: status.isMoving ? 'Moving' : 'Stopped',
                color: status.isMoving ? Colors.blue : Colors.grey,
              ),
              Container(width: 1, height: 50, color: Colors.grey.shade200),
              _buildStatusItem(
                icon: Icons.navigation_rounded,
                label: 'Direction',
                value: status.direction.toUpperCase(),
                color: Colors.indigo,
              ),
            ],
          ),
          const Divider(height: 24),

          // Obstacle proximity bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nearest Obstacle',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    // If no obstacle, show "Clear" — else show distance
                    status.obstacleDistance >= 999
                        ? 'Clear'
                        : '${status.obstacleDistance.toStringAsFixed(0)} cm',
                    style: TextStyle(
                      color: _obstacleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _obstacleBarValue,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade100,
                  color: _obstacleColor,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Danger <15cm',
                      style: TextStyle(fontSize: 10, color: Colors.red)),
                  Text('Warning <50cm',
                      style: TextStyle(fontSize: 10, color: Colors.orange)),
                  Text('Safe',
                      style: TextStyle(fontSize: 10, color: Colors.green)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Maps distance (0–100cm) to progress bar (0.0–1.0)
  // distance=0 → bar=0 (danger), distance=100+ → bar=1.0 (safe)
  double get _obstacleBarValue {
    if (status.obstacleDistance >= 999) return 1.0;
    return (status.obstacleDistance / 100).clamp(0.0, 1.0);
  }

  Color get _obstacleColor {
    if (status.obstacleDistance < 15) return Colors.red;
    if (status.obstacleDistance < 50) return Colors.orange;
    return Colors.green;
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
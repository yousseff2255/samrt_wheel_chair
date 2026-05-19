import 'package:flutter/material.dart';

class VitalCard extends StatelessWidget {
  final String label;        // e.g. "Heart Rate"
  final String value;        // e.g. "75"
  final String unit;         // e.g. "BPM"
  final IconData icon;
  final bool isAbnormal;     // Controls color (red vs green)
  final String normalRange;  // e.g. "50–100"

  const VitalCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.isAbnormal,
    required this.normalRange,
  });

  @override
  Widget build(BuildContext context) {
    // Pick color based on whether reading is abnormal
    final Color accentColor =
        isAbnormal ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAbnormal ? Colors.red.shade200 : Colors.green.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + warning sign (if abnormal)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 24),
              if (isAbnormal)
                const Icon(Icons.warning_rounded, color: Colors.red, size: 18),
            ],
          ),
          const SizedBox(height: 12),

          // Value + unit displayed together
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 2),
          Text('Normal: $normalRange',
              style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 6),

          // Status pill (NORMAL / ABNORMAL)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isAbnormal ? 'ABNORMAL' : 'NORMAL',
              style: TextStyle(
                color: accentColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
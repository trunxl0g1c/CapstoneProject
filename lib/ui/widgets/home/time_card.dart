import 'package:capstone/utils/time_utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as m;

class TimeCard extends StatelessWidget {
  const TimeCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.time,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final m.TimeOfDay? time;
  final m.IconData icon;
  final List<m.Color> gradientColors;
  final m.VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return m.GestureDetector(
      onTap: onTap,
      child: m.Container(
        padding: const m.EdgeInsets.all(16),
        decoration: m.BoxDecoration(
          color: m.Colors.white.withValues(alpha: 0.05),
          borderRadius: m.BorderRadius.circular(20),
          border: m.Border.all(color: m.Colors.white.withValues(alpha: 0.1)),
        ),
        child: m.Column(
          crossAxisAlignment: m.CrossAxisAlignment.start,
          children: [
            m.Row(
              children: [
                m.Container(
                  width: 32,
                  height: 32,
                  decoration: m.BoxDecoration(
                    shape: m.BoxShape.circle,
                    gradient: m.LinearGradient(
                      colors: gradientColors,
                      begin: m.Alignment.topLeft,
                      end: m.Alignment.bottomRight,
                    ),
                  ),
                  child: m.Icon(icon, color: m.Colors.white, size: 18),
                ),
              ],
            ),
            const m.SizedBox(height: 12),
            m.Text(
              title,
              style: const m.TextStyle(color: m.Colors.white70, fontSize: 12),
            ),
            const m.SizedBox(height: 8),
            m.Text(
              formatTime(time),
              style: const m.TextStyle(
                color: m.Colors.white,
                fontSize: 24,
                fontWeight: m.FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const m.SizedBox(height: 4),
            m.Text(
              subtitle,
              style: const m.TextStyle(color: m.Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

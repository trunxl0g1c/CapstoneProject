import 'package:flutter/material.dart' as m;
import 'dart:math' as math;

class CircularProgressPainter extends m.CustomPainter {
  final double progress;
  final double strokeWidth;

  CircularProgressPainter({required this.progress, this.strokeWidth = 12});

  @override
  void paint(m.Canvas canvas, m.Size size) {
    final center = m.Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = m.Paint()
      ..color = m.Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = m.PaintingStyle.stroke
      ..strokeCap = m.StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Gradient progress
    final rect = m.Rect.fromCircle(center: center, radius: radius);
    final gradient = m.SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 2 * math.pi - math.pi / 2,
      colors: [
        const m.Color(0xFF8B5CF6),
        const m.Color(0xFF06B6D4),
        const m.Color(0xFF8B5CF6),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final progressPaint = m.Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = m.PaintingStyle.stroke
      ..strokeCap = m.StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

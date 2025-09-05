import 'package:flutter/material.dart';
import 'package:elements_app/core/painter/base_pattern_painter.dart';

class ElementParticlesPainter extends BasePatternPainter {
  ElementParticlesPainter(Color color)
      : super(
          color: color,
          opacity: 0.1,
          drawGrid: false,
          drawCircles: false,
        );

  @override
  void drawAdditionalPatterns(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 2;

    // Draw animated particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    // Draw connecting lines
    for (int i = 0; i < 10; i++) {
      final x1 = (i * 67) % size.width;
      final y1 = (i * 41) % size.height;
      final x2 = ((i + 1) * 67) % size.width;
      final y2 = ((i + 1) * 41) % size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }
}

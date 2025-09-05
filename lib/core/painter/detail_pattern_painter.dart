import 'package:flutter/material.dart';
import 'dart:math' show cos, sin, pi;

final class DetailPatternPainter extends CustomPainter {
  final Color color;

  DetailPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Draw hexagonal pattern
    const double hexSize = 40;
    const double yOffset = hexSize * 0.866; // sqrt(3)/2

    for (double y = -hexSize; y < size.height + hexSize; y += yOffset * 2) {
      bool oddRow = false;
      for (double x = -hexSize; x < size.width + hexSize; x += hexSize * 1.5) {
        final double xOffset = oddRow ? hexSize * 0.75 : 0;
        _drawHexagon(canvas, paint, Offset(x + xOffset, y), hexSize);
        oddRow = !oddRow;
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * pi / 180;
      final point = Offset(
        center.dx + size * cos(angle),
        center.dy + size * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

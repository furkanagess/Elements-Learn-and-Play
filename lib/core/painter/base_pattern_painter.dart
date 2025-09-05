import 'package:flutter/material.dart';

/// Base pattern painter class that provides common functionality for all pattern painters
abstract class BasePatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double strokeWidth;
  final double gridSpacing;
  final bool drawGrid;
  final bool drawCircles;
  final int numberOfCircles;

  const BasePatternPainter({
    required this.color,
    this.opacity = 0.05,
    this.strokeWidth = 1,
    this.gridSpacing = 40,
    this.drawGrid = true,
    this.drawCircles = true,
    this.numberOfCircles = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (drawGrid) {
      _drawGridPattern(canvas, size);
    }

    if (drawCircles) {
      _drawCirclePattern(canvas, size);
    }

    // Allow subclasses to add additional patterns
    drawAdditionalPatterns(canvas, size);
  }

  /// Draws the base grid pattern
  void _drawGridPattern(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = strokeWidth;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  /// Draws circle patterns
  void _drawCirclePattern(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = color.withOpacity(opacity * 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < numberOfCircles; i++) {
      final x = (i * 80) % size.width;
      final y = (i * 60) % size.height;
      canvas.drawCircle(Offset(x, y), 20, circlePaint);
    }
  }

  /// Override this method to add additional patterns in subclasses
  void drawAdditionalPatterns(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

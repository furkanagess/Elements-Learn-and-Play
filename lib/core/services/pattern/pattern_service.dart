import 'dart:math';
import 'package:flutter/material.dart';

/// Centralized pattern service for managing background patterns
/// Provides optimized and cached pattern painters for better performance
class PatternService {
  static final PatternService _instance = PatternService._internal();
  factory PatternService() => _instance;
  PatternService._internal();

  // Cache for pattern painters to avoid recreating them
  final Map<String, CustomPainter> _patternCache = {};

  // Available pattern types
  static const List<PatternType> _availablePatterns = [
    PatternType.grid,
    PatternType.hexagon,
    PatternType.wave,
    PatternType.atomic,
    PatternType.molecular,
    PatternType.circuit,
    PatternType.crystal,
    PatternType.dna,
  ];

  /// Get a pattern painter based on seed and color
  /// Uses caching for better performance
  CustomPainter getPatternPainter({
    required PatternType type,
    required Color color,
    double opacity = 0.1,
  }) {
    final cacheKey = '${type.name}_${color.toARGB32()}_$opacity';

    if (_patternCache.containsKey(cacheKey)) {
      return _patternCache[cacheKey]!;
    }

    final painter =
        _createPatternPainter(type, color.withValues(alpha: opacity));
    _patternCache[cacheKey] = painter;
    return painter;
  }

  /// Get a random pattern painter based on seed
  CustomPainter getRandomPatternPainter({
    required int seed,
    required Color color,
    double opacity = 0.1,
  }) {
    final patternType = _availablePatterns[seed % _availablePatterns.length];
    return getPatternPainter(type: patternType, color: color, opacity: opacity);
  }

  /// Create a specific pattern painter
  CustomPainter _createPatternPainter(PatternType type, Color color) {
    switch (type) {
      case PatternType.grid:
        return GridPatternPainter(color: color);
      case PatternType.hexagon:
        return HexagonPatternPainter(color: color);
      case PatternType.wave:
        return WavePatternPainter(color: color);
      case PatternType.atomic:
        return AtomicPatternPainter(color: color);
      case PatternType.molecular:
        return MolecularPatternPainter(color: color);
      case PatternType.circuit:
        return CircuitPatternPainter(color: color);
      case PatternType.crystal:
        return CrystalPatternPainter(color: color);
      case PatternType.dna:
        return DnaPatternPainter(color: color);
    }
  }

  /// Clear the pattern cache (useful for memory management)
  void clearCache() {
    _patternCache.clear();
  }

  /// Get all available pattern types
  List<PatternType> get availablePatterns =>
      List.unmodifiable(_availablePatterns);
}

/// Enum for pattern types
enum PatternType {
  grid,
  hexagon,
  wave,
  atomic,
  molecular,
  circuit,
  crystal,
  dna,
}

/// Base pattern painter class with common functionality
abstract class BasePatternPainter extends CustomPainter {
  final Color color;

  BasePatternPainter({required this.color});

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}

/// Grid pattern with dots and lines
class GridPatternPainter extends BasePatternPainter {
  GridPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 30.0;

    // Draw dots
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }

    // Draw grid lines
    paint.strokeWidth = 0.5;
    paint.style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
}

/// Hexagonal pattern
class HexagonPatternPainter extends BasePatternPainter {
  HexagonPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const hexSize = 20.0;
    const spacing = hexSize * 1.5;

    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        _drawHexagon(canvas, Offset(x, y), hexSize, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * (pi / 3);
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

/// Wave pattern
class WavePatternPainter extends BasePatternPainter {
  WavePatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const waveHeight = 15.0;
    const waveLength = 40.0;

    for (double y = 0; y < size.height; y += waveLength) {
      final path = Path();
      path.moveTo(0, y);

      for (double x = 0; x <= size.width; x += 5) {
        final waveY = y + waveHeight * sin((x / waveLength) * 2 * pi);
        path.lineTo(x, waveY);
      }

      canvas.drawPath(path, paint);
    }
  }
}

/// Atomic structure pattern
class AtomicPatternPainter extends BasePatternPainter {
  AtomicPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw atomic structure
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.3;

    // Draw nucleus
    canvas.drawCircle(center, 4, paint);

    // Draw electron orbits
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;

    for (int i = 1; i <= 3; i++) {
      final orbitRadius = radius * (i / 3);
      canvas.drawCircle(center, orbitRadius, paint);

      // Draw electrons
      paint.style = PaintingStyle.fill;
      final electronCount = i * 2;
      for (int j = 0; j < electronCount; j++) {
        final angle = (j / electronCount) * 2 * pi;
        final electronX = center.dx + orbitRadius * cos(angle);
        final electronY = center.dy + orbitRadius * sin(angle);
        canvas.drawCircle(Offset(electronX, electronY), 2, paint);
      }
      paint.style = PaintingStyle.stroke;
    }
  }
}

/// Molecular bond pattern
class MolecularPatternPainter extends BasePatternPainter {
  MolecularPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 35.0;
    const bondLength = 25.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final center = Offset(x, y);

        // Draw atom
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(center, 3, paint);

        // Draw bonds
        paint.style = PaintingStyle.stroke;
        const angles = <int>[0, 60, 120, 180, 240, 300];
        for (final angle in angles) {
          final radians = angle * (pi / 180);
          final endX = center.dx + bondLength * cos(radians);
          final endY = center.dy + bondLength * sin(radians);
          canvas.drawLine(center, Offset(endX, endY), paint);
        }
      }
    }
  }
}

/// Circuit board pattern
class CircuitPatternPainter extends BasePatternPainter {
  CircuitPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 40.0;

    // Draw circuit lines
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final center = Offset(x, y);

        // Draw circuit nodes
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(center, 2, paint);

        // Draw connections
        paint.style = PaintingStyle.stroke;
        if (x + spacing < size.width) {
          canvas.drawLine(center, Offset(x + spacing, y), paint);
        }
        if (y + spacing < size.height) {
          canvas.drawLine(center, Offset(x, y + spacing), paint);
        }
      }
    }
  }
}

/// Crystal lattice pattern
class CrystalPatternPainter extends BasePatternPainter {
  CrystalPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 25.0;

    // Draw crystal lattice
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final center = Offset(x, y);

        // Draw crystal points
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(center, 1.5, paint);

        // Draw lattice connections
        paint.style = PaintingStyle.stroke;
        const connections = [
          Offset(spacing, 0),
          Offset(0, spacing),
          Offset(spacing, spacing),
          Offset(-spacing, spacing),
        ];

        for (final connection in connections) {
          final endPoint = center + connection;
          if (endPoint.dx >= 0 &&
              endPoint.dx <= size.width &&
              endPoint.dy >= 0 &&
              endPoint.dy <= size.height) {
            canvas.drawLine(center, endPoint, paint);
          }
        }
      }
    }
  }
}

/// DNA double helix pattern
class DnaPatternPainter extends BasePatternPainter {
  DnaPatternPainter({required super.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const helixWidth = 20.0;
    const helixSpacing = 30.0;

    // Draw DNA double helix
    for (double x = 0; x < size.width; x += helixSpacing) {
      final leftPath = Path();
      final rightPath = Path();

      bool isFirstPoint = true;

      for (double y = 0; y <= size.height; y += 5) {
        final leftX = x + helixWidth * sin((y / helixSpacing) * 2 * pi);
        final rightX = x + helixWidth * sin((y / helixSpacing) * 2 * pi + pi);

        if (isFirstPoint) {
          leftPath.moveTo(leftX, y);
          rightPath.moveTo(rightX, y);
          isFirstPoint = false;
        } else {
          leftPath.lineTo(leftX, y);
          rightPath.lineTo(rightX, y);
        }
      }

      canvas.drawPath(leftPath, paint);
      canvas.drawPath(rightPath, paint);

      // Draw connecting lines
      for (double y = 0; y <= size.height; y += helixSpacing) {
        final leftX = x + helixWidth * sin((y / helixSpacing) * 2 * pi);
        final rightX = x + helixWidth * sin((y / helixSpacing) * 2 * pi + pi);
        canvas.drawLine(Offset(leftX, y), Offset(rightX, y), paint);
      }
    }
  }
}

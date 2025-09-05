import 'package:flutter/material.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/product/constants/app_colors.dart';

final class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    // Vertical lines
    for (var i = 0; i <= size.width; i += 60) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    // Horizontal lines
    for (var i = 0; i <= size.height; i += 60) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Lantanit ve Aktinit bölgeleri için özel çizgiler
    final specialPaint = Paint()
      ..color = AppColors.white.withOpacity(0.1)
      ..strokeWidth = 2;

    // Lantanit bölgesi (8. satır)
    canvas.drawRect(
      Rect.fromLTWH(180, 480, 840, 60),
      specialPaint,
    );

    // Aktinit bölgesi (9. satır)
    canvas.drawRect(
      Rect.fromLTWH(180, 540, 840, 60),
      specialPaint,
    );

    // Bağlantı çizgileri
    final arrowPaint = Paint()
      ..color = AppColors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Lantanit bağlantısı (La -> Ce)
    canvas.drawPath(
      Path()
        ..moveTo(120, 300) // La
        ..lineTo(140, 300)
        ..lineTo(140, 480)
        ..lineTo(180, 480), // Ce
      arrowPaint,
    );

    // Aktinit bağlantısı (Ac -> Th)
    canvas.drawPath(
      Path()
        ..moveTo(120, 360) // Ac
        ..lineTo(160, 360)
        ..lineTo(160, 540)
        ..lineTo(180, 540), // Th
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final class ElectronicConfigPainter extends CustomPainter {
  final PeriodicElement element;

  ElectronicConfigPainter({required this.element});

  @override
  void paint(Canvas canvas, Size size) {
    // Elektronik konfigürasyon görselleştirmesi
    // TODO: Implement electronic configuration visualization
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

final class AtomicModelPainter extends CustomPainter {
  final PeriodicElement element;

  AtomicModelPainter({required this.element});

  @override
  void paint(Canvas canvas, Size size) {
    // Atom modeli görselleştirmesi
    // TODO: Implement atomic model visualization
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

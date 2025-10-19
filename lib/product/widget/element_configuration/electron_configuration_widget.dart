import 'dart:math';
import 'package:flutter/material.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/product/constants/app_colors.dart';

class ElectronConfigurationWidget extends StatelessWidget {
  final PeriodicElement element;

  const ElectronConfigurationWidget({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    final electronCount = element.number ?? 0;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple.withValues(alpha: 0.15),
            AppColors.pink.withValues(alpha: 0.12),
            AppColors.turquoise.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background atomic pattern
            Positioned.fill(
              child: CustomPaint(
                painter: AtomicPatternPainter(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Electron configuration visualization
            Center(child: _buildElectronConfiguration(electronCount)),
            // Title
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Text(
                'Electron Configuration',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectronConfiguration(int electronCount) {
    final shells = _calculateElectronShells(electronCount);

    return CustomPaint(
      painter: ElectronShellsPainter(
        shells: shells,
        electronCount: electronCount,
      ),
      size: const Size(200, 200),
    );
  }

  List<int> _calculateElectronShells(int electronCount) {
    final shells = <int>[];
    int remaining = electronCount;

    // Electron shell capacity: 2, 8, 8, 18, 18, 32, 32
    final shellCapacity = [2, 8, 8, 18, 18, 32, 32];

    for (int capacity in shellCapacity) {
      if (remaining <= 0) break;

      final electronsInShell = min(remaining, capacity);
      shells.add(electronsInShell);
      remaining -= electronsInShell;
    }

    return shells;
  }
}

class ElectronShellsPainter extends CustomPainter {
  final List<int> shells;
  final int electronCount;

  ElectronShellsPainter({required this.shells, required this.electronCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw nucleus
    final nucleusPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, nucleusPaint);

    // Draw nucleus border
    final nucleusBorderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 8, nucleusBorderPaint);

    // Draw electron shells
    final shellPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final electronPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final electronBorderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < shells.length; i++) {
      final radius = 20.0 + (i * 25.0);
      final electronsInShell = shells[i];

      // Draw shell orbit
      canvas.drawCircle(center, radius, shellPaint);

      // Draw electrons in this shell
      for (int j = 0; j < electronsInShell; j++) {
        final angle = (j / electronsInShell) * 2 * pi;
        final electronX = center.dx + radius * cos(angle);
        final electronY = center.dy + radius * sin(angle);
        final electronCenter = Offset(electronX, electronY);

        // Draw electron
        canvas.drawCircle(electronCenter, 3, electronPaint);
        canvas.drawCircle(electronCenter, 3, electronBorderPaint);

        // Draw electron movement indicator (small trail)
        final trailPaint = Paint()
          ..color = AppColors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

        final trailAngle = angle + 0.1;
        final trailX = electronCenter.dx + 6.0 * cos(trailAngle);
        final trailY = electronCenter.dy + 6.0 * sin(trailAngle);
        canvas.drawLine(electronCenter, Offset(trailX, trailY), trailPaint);
      }
    }

    // Element symbol removed as requested
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AtomicPatternPainter extends CustomPainter {
  final Color color;

  AtomicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw multiple atomic structures scattered across the background
    final centers = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.8),
    ];

    for (final center in centers) {
      final radius = min(size.width, size.height) * 0.08;

      // Draw nucleus
      canvas.drawCircle(center, 2, paint);

      // Draw electron orbits
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 0.5;

      for (int i = 1; i <= 2; i++) {
        final orbitRadius = radius * (i / 2);
        canvas.drawCircle(center, orbitRadius, paint);

        // Draw electrons
        paint.style = PaintingStyle.fill;
        final electronCount = i * 2;
        for (int j = 0; j < electronCount; j++) {
          final angle = (j / electronCount) * 2 * pi;
          final electronX = center.dx + orbitRadius * cos(angle);
          final electronY = center.dy + orbitRadius * sin(angle);
          canvas.drawCircle(Offset(electronX, electronY), 1, paint);
        }
        paint.style = PaintingStyle.stroke;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

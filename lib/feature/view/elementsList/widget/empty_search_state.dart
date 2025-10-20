import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

/// Modern empty state component shown when search returns no results
class EmptySearchState extends StatefulWidget {
  const EmptySearchState({super.key});

  @override
  State<EmptySearchState> createState() => _EmptySearchStateState();
}

class _EmptySearchStateState extends State<EmptySearchState>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main illustration container
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: _buildMainIllustration(),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Title
            _buildTitle(isTr),

            const SizedBox(height: 16),

            // Description
            _buildDescription(isTr),
          ],
        ),
      ),
    );
  }

  Widget _buildMainIllustration() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue,
            AppColors.steelBlue.withValues(alpha: 0.8),
            AppColors.purple.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.glowGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowGreen.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(painter: ModernEmptyStatePatternPainter()),
          ),
          // Lottie animation
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Lottie.asset(
                AssetConstants.instance.lottieSearch,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
          // Floating elements
          ..._buildFloatingElements(),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    return [
      // Top right floating element
      Positioned(
        top: 16,
        right: 16,
        child: _buildFloatingElement(
          icon: Icons.search_off,
          color: AppColors.powderRed,
          delay: 0,
        ),
      ),
      // Bottom left floating element
      Positioned(
        bottom: 16,
        left: 16,
        child: _buildFloatingElement(
          icon: Icons.help_outline,
          color: AppColors.turquoise,
          delay: 500,
        ),
      ),
    ];
  }

  Widget _buildFloatingElement({
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1000 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildTitle(bool isTr) {
    return Text(
      isTr ? 'Arama Sonucu Bulunamadı' : 'No Search Results Found',
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription(bool isTr) {
    return Text(
      isTr
          ? 'Aradığınız element bulunamadı. Farklı anahtar kelimeler deneyin veya aşağıdaki önerileri inceleyin.'
          : 'The element you searched for was not found. Try different keywords or check out the suggestions below.',
      style: TextStyle(
        color: AppColors.white.withValues(alpha: 0.7),
        fontSize: 16,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Modern custom painter for empty state background pattern
class ModernEmptyStatePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle grid pattern
    final gridPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        gridPaint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        gridPaint,
      );
    }

    // Draw molecular-like connections
    final connectionPaint = Paint()
      ..color = AppColors.glowGreen.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Create molecular structure pattern
    final points = <Offset>[];
    for (int x = 0; x < size.width; x += 50) {
      for (int y = 0; y < size.height; y += 50) {
        points.add(Offset(x.toDouble(), y.toDouble()));
      }
    }

    // Draw connections between nearby points
    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance < 80) {
          canvas.drawLine(points[i], points[j], connectionPaint);
        }
      }
    }

    // Draw nodes at intersections
    final nodePaint = Paint()
      ..color = AppColors.glowGreen.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 2.5, nodePaint);
    }

    // Add floating particles
    final particlePaint = Paint()
      ..color = AppColors.turquoise.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = (i * 45) % size.width;
      final y = (i * 45) % size.height;
      final radius = 1.5 + (i % 3);

      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        radius,
        particlePaint,
      );
    }

    // Add subtle glow effects
    final glowPaint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw soft glow circles
    for (int i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final y = size.height * (0.3 + i * 0.2);

      canvas.drawCircle(Offset(x, y), 25 + i * 10, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

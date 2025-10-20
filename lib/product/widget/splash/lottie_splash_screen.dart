import 'package:elements_app/product/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Lottie-based splash screen widget
class LottieSplashScreen extends StatefulWidget {
  final VoidCallback? onAnimationComplete;
  final Duration? duration;

  const LottieSplashScreen({
    super.key,
    this.onAnimationComplete,
    this.duration,
  });

  @override
  State<LottieSplashScreen> createState() => _LottieSplashScreenState();
}

class _LottieSplashScreenState extends State<LottieSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.duration ?? const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startAnimation() {
    // Start infinite loop animation
    _animationController.repeat();

    // Call completion callback after duration
    Future.delayed(widget.duration ?? const Duration(seconds: 3), () {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animation - much larger
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Lottie.asset(
                    'assets/lottie/Chemicals.json',
                    controller: _animationController,
                    fit: BoxFit.contain,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.science,
                        size: 120,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // App title
                Text(
                  'Periodic Table',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                // Subtitle
                Text(
                  'Learn & Explore Chemical Elements',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

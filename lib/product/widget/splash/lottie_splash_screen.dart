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
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              SizedBox(
                width: 300,
                height: 300,
                child: Lottie.asset(
                  'assets/lottie/Chemicals.json',
                  controller: _animationController,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),

              const SizedBox(height: 40),

              // App Title
              Text(
                'Periodic Table',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Learn and explore chemical elements',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

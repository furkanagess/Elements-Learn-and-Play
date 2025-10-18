import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/skeleton/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

/// Modern loading indicator with progress animation
class ModernLoadingIndicator extends StatefulWidget {
  final String? loadingText;
  final double progress;
  final bool showProgress;
  final Color? primaryColor;
  final Color? secondaryColor;

  const ModernLoadingIndicator({
    super.key,
    this.loadingText,
    this.progress = 0.0,
    this.showProgress = false,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final isTr = localizationProvider.isTr;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main loading animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                        colors: [
                          widget.primaryColor ?? AppColors.purple,
                          widget.secondaryColor ?? AppColors.pink,
                          AppColors.turquoise,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.primaryColor ?? AppColors.purple)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      AssetConstants.instance.lottieLoadingChemistry,
                      fit: BoxFit.cover,
                      repeat: true,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Loading text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                widget.loadingText ??
                    (isTr
                        ? TrAppStrings.loadingElements
                        : EnAppStrings.loadingElements),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (widget.showProgress) ...[
              const SizedBox(height: 20),
              _buildProgressIndicator(),
            ],

            const SizedBox(height: 16),
            _buildAnimatedDots(),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      width: 200,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) {
              return Container(
                width: 200 * widget.progress,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.primaryColor ?? AppColors.purple,
                      widget.secondaryColor ?? AppColors.pink,
                      AppColors.turquoise,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.primaryColor ?? AppColors.purple)
                          .withValues(alpha: 0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6 + (value * 4),
              height: 6 + (value * 4),
              decoration: BoxDecoration(
                color: (widget.primaryColor ?? AppColors.purple).withValues(
                  alpha: 0.3 + (value * 0.7),
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.primaryColor ?? AppColors.purple).withValues(
                      alpha: 0.5,
                    ),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
          onEnd: () {
            // Restart animation
          },
        );
      }),
    );
  }
}

/// Skeleton loading with modern shimmer effect
class SkeletonLoadingCard extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SkeletonLoadingCard({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// Modern loading overlay for full screen
class ModernLoadingOverlay extends StatelessWidget {
  final String? loadingText;
  final double progress;
  final bool showProgress;
  final Color? backgroundColor;

  const ModernLoadingOverlay({
    super.key,
    this.loadingText,
    this.progress = 0.0,
    this.showProgress = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.background.withValues(alpha: 0.8),
      child: Center(
        child: ModernLoadingIndicator(
          loadingText: loadingText,
          progress: progress,
          showProgress: showProgress,
        ),
      ),
    );
  }
}

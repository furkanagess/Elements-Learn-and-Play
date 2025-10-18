import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/periodicTable/periodic_table_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HeroSectionWidget extends StatefulWidget {
  const HeroSectionWidget({super.key});

  @override
  State<HeroSectionWidget> createState() => _HeroSectionWidgetState();
}

class _HeroSectionWidgetState extends State<HeroSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    // Add haptic feedback
    HapticFeedback.lightImpact();
    _navigateToPeriodicTable(context);
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  void _navigateToPeriodicTable(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PeriodicTableView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final isTr = localizationProvider.isTr;

        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white.withValues(
                      alpha: 0.1,
                    ), // Opacity white background
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ), // Opacity white border
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Row(
                        children: [
                          // Periodic Table Image (Left Side)
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Image.asset(
                                AssetConstants.instance.pngHomeImage,
                                height: 160,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Text Content (Right Side) with 3D Effect - Centered
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.glowGreen.withValues(
                                        alpha: 0.4,
                                      ),
                                      AppColors.yellow.withValues(alpha: 0.4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.glowGreen.withValues(
                                      alpha: 0.6,
                                    ),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shGlowGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: AppColors.shYellow.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, -3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  isTr
                                      ? TrAppStrings.periodicTable
                                      : EnAppStrings.periodicTable,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

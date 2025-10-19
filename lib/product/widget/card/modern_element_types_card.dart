import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Modern element types card with new UI design
class ModernElementTypesCard extends StatefulWidget {
  final VoidCallback? onTap;
  final EdgeInsets? margin;

  const ModernElementTypesCard({super.key, this.onTap, this.margin});

  @override
  State<ModernElementTypesCard> createState() => _ModernElementTypesCardState();
}

class _ModernElementTypesCardState extends State<ModernElementTypesCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _cardAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: (_) => _cardController.forward(),
        onTapUp: (_) => _handleTap(),
        onTapCancel: () => _cardController.reverse(),
        child: AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimation.value,
              child: Container(
                decoration: _buildCardDecoration(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build card decoration with modern styling
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: AppColors.purple.withValues(alpha: 0.15), // Purple background
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.purple.withValues(alpha: 0.4), // Purple border
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.purple.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Build main content
  Widget _buildContent() {
    return Row(
      children: [
        // Icon container
        _buildIconContainer(),

        const SizedBox(width: 16),

        // Text content
        Expanded(child: _buildTextContent()),

        // Arrow icon
        _buildArrowIcon(),
      ],
    );
  }

  /// Build icon container
  Widget _buildIconContainer() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          AssetConstants.instance.svgQuestionTwo,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
      ),
    );
  }

  /// Build text content
  Widget _buildTextContent() {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final isTr = localizationProvider.isTr;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              isTr ? TrAppStrings.elementTypes : EnAppStrings.elementTypes,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              isTr ? 'Element türlerini keşfet' : 'Discover element types',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  /// Build arrow icon
  Widget _buildArrowIcon() {
    return Icon(
      Icons.chevron_right_rounded,
      color: const Color(0xFFB0B0B0), // Light gray for better contrast
      size: 24,
    );
  }

  /// Handle card tap
  void _handleTap() {
    _cardController.reverse();
    HapticFeedback.lightImpact();

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
}

/// Modern info card for element types list
class ModernInfoCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final Color? iconColor;

  const ModernInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconPath,
    this.onTap,
    this.margin,
    this.iconColor,
  });

  @override
  State<ModernInfoCard> createState() => _ModernInfoCardState();
}

class _ModernInfoCardState extends State<ModernInfoCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTapDown: (_) => _cardController.forward(),
        onTapUp: (_) => _handleTap(),
        onTapCancel: () => _cardController.reverse(),
        child: AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (widget.iconColor ?? AppColors.steelBlue).withValues(
                    alpha: 0.15,
                  ), // Element color background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (widget.iconColor ?? AppColors.steelBlue).withValues(
                      alpha: 0.4,
                    ), // Element color border
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.iconColor ?? AppColors.steelBlue)
                          .withValues(alpha: 0.3),
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
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? AppColors.steelBlue)
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (widget.iconColor ?? AppColors.steelBlue)
                              .withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.iconColor ?? AppColors.steelBlue)
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          widget.iconPath,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFFB0B0B0),
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Handle card tap
  void _handleTap() {
    _cardController.reverse();
    HapticFeedback.lightImpact();

    if (widget.onTap != null) {
      widget.onTap!();
    }
  }
}

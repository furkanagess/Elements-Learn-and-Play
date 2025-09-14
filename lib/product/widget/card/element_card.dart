import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/favorite_elements_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Enum for different element card display modes
enum ElementCardMode { list, grid, favorites }

/// Unified element card widget that can display elements in different modes
class ElementCard extends StatefulWidget {
  final PeriodicElement element;
  final ElementCardMode mode;
  final int index;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const ElementCard({
    super.key,
    required this.element,
    required this.mode,
    required this.index,
    this.onTap,
    this.showFavoriteButton = false,
  });

  @override
  State<ElementCard> createState() => _ElementCardState();
}

class _ElementCardState extends State<ElementCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  final PatternService _patternService = PatternService();

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
    final elementColors = _getElementColors();
    final isTr = context.watch<LocalizationProvider>().isTr;

    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            margin: _getCardMargin(),
            decoration: _buildCardDecoration(elementColors),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTapDown: (_) => _cardController.forward(),
                onTapUp: (_) => _handleTap(),
                onTapCancel: () => _cardController.reverse(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _patternService.getRandomPatternPainter(
                            seed: widget.element.number ?? widget.index,
                            color: Colors.white,
                            opacity: 0.1,
                          ),
                        ),
                      ),

                      // Decorative Elements
                      ..._buildDecorativeElements(),

                      // Main Content
                      Padding(
                        padding: _getContentPadding(),
                        child: _buildContent(isTr, elementColors),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get element colors with fallback
  Map<String, Color> _getElementColors() {
    Color elementColor;
    Color shadowColor;

    try {
      if (widget.element.colors is String) {
        elementColor = (widget.element.colors as String).toColor();
      } else if (widget.element.colors != null) {
        elementColor = widget.element.colors!.toColor();
      } else {
        elementColor = AppColors.darkBlue;
      }

      if (widget.element.shColor is String) {
        shadowColor = (widget.element.shColor as String).toColor();
      } else if (widget.element.shColor != null) {
        shadowColor = widget.element.shColor!.toColor();
      } else {
        shadowColor = AppColors.background;
      }
    } catch (e) {
      elementColor = AppColors.darkBlue;
      shadowColor = AppColors.background;
    }

    return {'element': elementColor, 'shadow': shadowColor};
  }

  /// Build card decoration based on mode
  BoxDecoration _buildCardDecoration(Map<String, Color> colors) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: LinearGradient(
        colors: [
          colors['element']!.withValues(alpha: 0.9),
          colors['element']!.withValues(alpha: 0.7),
          colors['element']!.withValues(alpha: 0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.6, 1.0],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: colors['shadow']!.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: colors['shadow']!.withValues(alpha: 0.2),
          blurRadius: 40,
          offset: const Offset(0, 20),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Get card margin based on mode
  EdgeInsets _getCardMargin() {
    switch (widget.mode) {
      case ElementCardMode.list:
      case ElementCardMode.favorites:
        return const EdgeInsets.only(bottom: 16);
      case ElementCardMode.grid:
        return EdgeInsets.zero;
    }
  }

  /// Get content padding based on mode
  EdgeInsets _getContentPadding() {
    switch (widget.mode) {
      case ElementCardMode.list:
      case ElementCardMode.favorites:
        return const EdgeInsets.all(20);
      case ElementCardMode.grid:
        return const EdgeInsets.all(16);
    }
  }

  /// Build decorative elements based on mode
  List<Widget> _buildDecorativeElements() {
    switch (widget.mode) {
      case ElementCardMode.list:
      case ElementCardMode.favorites:
        return [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            left: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ];
      case ElementCardMode.grid:
        return [
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -8,
            left: -8,
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ];
    }
  }

  /// Build main content based on mode
  Widget _buildContent(bool isTr, Map<String, Color> colors) {
    switch (widget.mode) {
      case ElementCardMode.list:
        return _buildListContent(isTr);
      case ElementCardMode.grid:
        return _buildGridContent(isTr);
      case ElementCardMode.favorites:
        return _buildFavoritesContent(isTr);
    }
  }

  /// Build list mode content
  Widget _buildListContent(bool isTr) {
    return Row(
      children: [
        // Element number
        _buildElementNumber(60, 20),
        const SizedBox(width: 20),

        // Element info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Element symbol
              Text(
                widget.element.symbol ?? '',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),

              // Element name
              Text(
                isTr
                    ? widget.element.trName ?? ''
                    : widget.element.enName ?? '',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),

              // Atomic weight
              _buildWeightContainer(),
            ],
          ),
        ),

        // Arrow icon
        _buildArrowIcon(),
      ],
    );
  }

  /// Build grid mode content
  Widget _buildGridContent(bool isTr) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Element number
        Center(child: _buildElementNumber(40, 16)),
        const SizedBox(height: 12),

        // Element symbol
        Center(
          child: Text(
            widget.element.symbol ?? '',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),

        // Element name
        Center(
          child: Text(
            isTr ? widget.element.trName ?? '' : widget.element.enName ?? '',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 8),

        // Element weight
        Center(child: _buildGridWeightContainer()),
      ],
    );
  }

  /// Build favorites mode content
  Widget _buildFavoritesContent(bool isTr) {
    return Row(
      children: [
        // Element number
        _buildElementNumber(60, 20),
        const SizedBox(width: 20),

        // Element info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.element.symbol ?? '',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isTr
                    ? widget.element.trName ?? ''
                    : widget.element.enName ?? '',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatWeight(widget.element.weight),
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Favorite button
        if (widget.showFavoriteButton) _buildFavoriteButton(),
      ],
    );
  }

  /// Build element number container
  Widget _buildElementNumber(double size, double fontSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(size == 40 ? 12 : 16),
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
        child: Text(
          widget.element.number?.toString() ?? '',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            shadows: widget.mode == ElementCardMode.favorites
                ? [
                    const Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  /// Build weight container for list mode
  Widget _buildWeightContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formatWeight(widget.element.weight),
        style: TextStyle(
          color: AppColors.white.withValues(alpha: 0.8),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  /// Build weight container for grid mode
  Widget _buildGridWeightContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formatWeight(widget.element.weight),
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build arrow icon for list mode
  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.white,
        size: 16,
      ),
    );
  }

  /// Build favorite button for favorites mode
  Widget _buildFavoriteButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.favorite, color: AppColors.white, size: 24),
        onPressed: () {
          HapticFeedback.lightImpact();
          context.read<FavoriteElementsProvider>().toggleFavorite(
            widget.element,
          );
        },
      ),
    );
  }

  /// Handle card tap
  void _handleTap() {
    _cardController.reverse();
    HapticFeedback.lightImpact();

    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ElementDetailView(element: widget.element),
        ),
      );
    }
  }

  /// Format weight string to show 4 decimal places
  String _formatWeight(String? weight) {
    if (weight == null || weight.isEmpty) return '';

    final doubleValue = double.tryParse(weight.replaceAll(',', '.'));
    if (doubleValue != null) {
      return doubleValue.toStringAsFixed(4);
    }

    return weight;
  }
}

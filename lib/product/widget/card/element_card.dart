import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/favorite_elements_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
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

  // Pattern service for background patterns
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
            child: GestureDetector(
              onTapDown: (_) => _cardController.forward(),
              onTapUp: (_) => _handleTap(),
              onTapCancel: () => _cardController.reverse(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background Pattern - Atomic pattern like element of day
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _patternService.getPatternPainter(
                          type: PatternType.atomic,
                          color: Colors.white,
                          opacity: 0.05,
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
    // Same decoration for list, grid, and favorites modes
    final cardBackgroundColor = _getCardBackgroundColor();
    final elementColor = colors['element']!;

    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: elementColor.withValues(alpha: 0.4), // Element color border
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: elementColor.withValues(alpha: 0.3), // Element color shadow
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
        return const EdgeInsets.all(
          14,
        ); // Slightly smaller padding for better content fit
    }
  }

  /// Build decorative elements based on mode
  List<Widget> _buildDecorativeElements() {
    // No decorative elements for all modes to keep them clean
    return [];
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
        // Element symbol icon (rounded square)
        _buildElementSymbolIcon(),
        const SizedBox(width: 16),

        // Element info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Element name
              Text(
                isTr
                    ? widget.element.trName ?? ''
                    : widget.element.enName ?? '',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Atomic number
              Text(
                isTr
                    ? 'Atom Numarası: ${widget.element.number ?? ''}'
                    : 'Atomic Number: ${widget.element.number ?? ''}',
                style: const TextStyle(
                  color: Color(
                    0xFFE0E0E0,
                  ), // Light gray text for better contrast
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1.2,
                ),
              ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row with symbol icon and atomic number
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Element symbol icon (top-left)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getGroupColor(), // Group color
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: _getGroupColor().withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.element.symbol ?? '',
                  style: TextStyle(
                    color: _getOriginalGroupColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
              ),
            ),

            // Atomic number (top-right)
            Text(
              '${widget.element.number ?? ''}',
              style: const TextStyle(
                color: Color(0xFFB0B0B0), // Light gray
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Element name and atomic weight on same row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Element name (left side)
            Expanded(
              child: Text(
                isTr
                    ? widget.element.trName ?? ''
                    : widget.element.enName ?? '',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            // Atomic weight (right side)
            Flexible(
              child: Text(
                _formatWeight(widget.element.weight),
                style: const TextStyle(
                  color: Color(0xFFB0B0B0), // Light gray
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build favorites mode content (same as list mode but without arrow)
  Widget _buildFavoritesContent(bool isTr) {
    return Row(
      children: [
        // Element symbol icon (rounded square)
        _buildElementSymbolIcon(),
        const SizedBox(width: 16),

        // Element info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Element name
              Text(
                isTr
                    ? widget.element.trName ?? ''
                    : widget.element.enName ?? '',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Atomic number
              Text(
                '${widget.element.number ?? ''}',
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

  /// Build element symbol icon (rounded square)
  Widget _buildElementSymbolIcon() {
    final groupColor = _getGroupColor();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: groupColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: groupColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.element.symbol ?? '',
          style: TextStyle(
            color: _getOriginalGroupColor(),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  /// Get group-based color for element symbol (opacity version for container background)
  Color _getGroupColor() {
    final category = widget.element.enCategory?.toLowerCase();

    switch (category) {
      case 'alkaline metal':
        return AppColors.turquoise.withValues(alpha: 0.3); // Opacity turquoise
      case 'alkaline earth metal':
        return AppColors.yellow.withValues(alpha: 0.3); // Opacity yellow
      case 'transition metal':
        return AppColors.purple.withValues(alpha: 0.3); // Opacity purple
      case 'post-transition metal':
        return AppColors.steelBlue.withValues(alpha: 0.3); // Opacity steel blue
      case 'metalloid':
        return AppColors.skinColor.withValues(alpha: 0.3); // Opacity skin color
      case 'reactive nonmetal':
        return AppColors.powderRed.withValues(alpha: 0.3); // Opacity red
      case 'noble gas':
        return AppColors.glowGreen.withValues(alpha: 0.3); // Opacity green
      case 'halogen':
        return AppColors.lightGreen.withValues(
          alpha: 0.3,
        ); // Opacity light green
      case 'lanthanide':
        return AppColors.darkTurquoise.withValues(
          alpha: 0.3,
        ); // Opacity turquoise
      case 'actinide':
        return AppColors.pink.withValues(alpha: 0.3); // Opacity pink
      default:
        return AppColors.darkWhite.withValues(alpha: 0.3); // Opacity default
    }
  }

  /// Get original group color for text (full opacity)
  Color _getOriginalGroupColor() {
    final category = widget.element.enCategory?.toLowerCase();

    switch (category) {
      case 'alkaline metal':
        return AppColors.white; // Full turquoise
      case 'alkaline earth metal':
        return AppColors.white; // Full yellow
      case 'transition metal':
        return AppColors.white; // Full purple
      case 'post-transition metal':
        return AppColors.white; // Full steel blue
      case 'metalloid':
        return AppColors.white; // Full skin color
      case 'reactive nonmetal':
        return AppColors.white; // Full red
      case 'noble gas':
        return AppColors.white; // Full green
      case 'halogen':
        return AppColors.white; // Full light green
      case 'lanthanide':
        return AppColors.white; // Full turquoise
      case 'actinide':
        return AppColors.white; // Full pink
      default:
        return AppColors.white; // Full default
    }
  }

  /// Get card background color - element color with opacity
  Color _getCardBackgroundColor() {
    final elementColors = _getElementColors();
    final elementColor = elementColors['element']!;

    // Use element color with low opacity for background
    return elementColor.withValues(alpha: 0.15);
  }

  /// Build element number container

  /// Build arrow icon for list mode
  Widget _buildArrowIcon() {
    return Icon(
      Icons.chevron_right_rounded,
      color: const Color(0xFFB0B0B0), // Medium gray for better contrast
      size: 24,
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

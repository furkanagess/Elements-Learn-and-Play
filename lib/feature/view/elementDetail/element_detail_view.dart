import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/favorite_elements_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/feature/view/favorites/favorites_view.dart';
import 'package:elements_app/feature/view/settings/settings_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/product/widget/element_configuration/electron_configuration_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Data class for detail card items
class DetailItem {
  final String label;
  final String value;
  final IconData? icon;
  final String? svgPath;
  final Color? valueColor;
  final bool isHighlighted;
  final String? unit;

  const DetailItem({
    required this.label,
    required this.value,
    this.icon,
    this.svgPath,
    this.valueColor,
    this.isHighlighted = false,
    this.unit,
  });

  /// Creates a DetailItem with a highlighted value
  const DetailItem.highlighted({
    required this.label,
    required this.value,
    this.icon,
    this.svgPath,
    this.valueColor,
    this.unit,
  }) : isHighlighted = true;

  /// Creates a DetailItem with a unit
  const DetailItem.withUnit({
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.svgPath,
    this.valueColor,
    this.isHighlighted = false,
  });

  /// Gets the display value with unit if available
  String get displayValue => unit != null ? '$value $unit' : value;
}

class ElementDetailView extends StatefulWidget {
  final PeriodicElement element;
  const ElementDetailView({super.key, required this.element});

  @override
  State<ElementDetailView> createState() => _ElementDetailViewState();
}

class _ElementDetailViewState extends State<ElementDetailView>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  // Removed unused _cardAnimationController to satisfy lints
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentTabIndex = 0;
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // card animation controller removed

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainAnimationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    super.dispose();
  }

  /// Formats the weight string to show 4 decimal places
  String _formatWeight(String? weight) {
    if (weight == null || weight.isEmpty) return '';

    // Try to parse as double and format to 4 decimal places
    final doubleValue = double.tryParse(weight.replaceAll(',', '.'));
    if (doubleValue != null) {
      return doubleValue.toStringAsFixed(2);
    }

    // If parsing fails, return original value
    return weight;
  }

  /// Gets the category text with fallback
  String _getCategoryText(bool isTr) {
    String category = isTr
        ? (widget.element.trCategory ?? '')
        : (widget.element.enCategory ?? '');

    // If category is empty, try the other language
    if (category.isEmpty) {
      category = isTr
          ? (widget.element.enCategory ?? '')
          : (widget.element.trCategory ?? '');
    }

    // If still empty, use group as fallback (localized)
    if (category.isEmpty) {
      category = widget.element.group ?? (isTr ? 'Bilinmiyor' : 'Unknown');
    }

    return category.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    Color elementColor;

    try {
      if (widget.element.colors is String) {
        elementColor = (widget.element.colors as String).toColor();
      } else if (widget.element.colors != null) {
        elementColor = widget.element.colors!.toColor();
      } else {
        elementColor = AppColors.darkBlue;
      }
    } catch (e) {
      elementColor = AppColors.darkBlue;
    }

    final isTr = Provider.of<LocalizationProvider>(context).isTr;

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context, elementColor, isTr),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    // Hero Header
                    _buildHeroHeader(context, elementColor, isTr),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Quick Stats Cards
                          _buildQuickStatsCards(context, elementColor),
                          const SizedBox(height: 24),

                          // Tab Navigation
                          _buildTabNavigation(context, elementColor),
                          const SizedBox(height: 20),

                          // Tab Content
                          _buildTabContent(context, elementColor, isTr),

                          const SizedBox(height: 100), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, Color elementColor, bool isTr) {
    return AppBar(
      backgroundColor: elementColor,
      leading: const ModernBackButton(),
      actions: _buildActionButtons(elementColor),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  Widget _buildHeroHeader(BuildContext context, Color elementColor, bool isTr) {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            elementColor.withValues(alpha: 0.2),
            elementColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: elementColor.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Pattern (match Element of the Day)
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.05,
                ),
              ),
            ),

            // Decorative Elements (match Element of the Day)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: elementColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: elementColor.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Main content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top row - Element number and symbol
                    Row(
                      children: [
                        // Element number with modern design
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.white.withValues(alpha: 0.25),
                                AppColors.white.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.element.number?.toString() ?? '',
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Element symbol with enhanced styling
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.white.withValues(alpha: 0.2),
                                  AppColors.white.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.element.symbol ?? '',
                              style: context.textTheme.displayLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 32,
                                height: 1.0,
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Bottom row - Element name and category
                    Row(
                      children: [
                        // Element name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ELEMENT',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isTr
                                    ? widget.element.trName ?? ''
                                    : widget.element.enName ?? '',
                                style: context.textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Category badge - now takes more space
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.white.withValues(alpha: 0.25),
                                  AppColors.white.withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _getCategoryText(isTr),
                                style: context.textTheme.titleSmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(Color elementColor) {
    return [
      Consumer2<FavoriteElementsProvider, PurchaseProvider>(
        builder: (context, favoriteProvider, purchaseProvider, child) {
          final isFavorite = favoriteProvider.isFavorite(widget.element);
          final isPremium = purchaseProvider.isPremium;
          final canAddFavorite = favoriteProvider.canAddFavorite(
            isPremium: isPremium,
          );

          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: AppColors.white,
              ),
              onPressed: () {
                final isTr = context.read<LocalizationProvider>().isTr;

                if (isFavorite) {
                  // Remove from favorites
                  favoriteProvider.toggleFavorite(
                    widget.element,
                    isPremium: isPremium,
                  );
                  final message = isTr
                      ? 'Favorilerden kaldırıldı'
                      : 'Removed from favorites';

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: elementColor,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                } else {
                  // Add to favorites
                  if (canAddFavorite) {
                    favoriteProvider.toggleFavorite(
                      widget.element,
                      isPremium: isPremium,
                    );
                    final message = isTr
                        ? 'Favorilere eklendi'
                        : 'Added to favorites';

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: GestureDetector(
                            onTap: () {
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FavoritesView(),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Expanded(child: Text(message)),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.white.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                          backgroundColor: elementColor,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  } else {
                    // Show premium upgrade dialog
                    _showPremiumUpgradeDialog(context, isTr);
                  }
                }
              },
            ),
          );
        },
      ),
    ];
  }

  void _showPremiumUpgradeDialog(BuildContext context, bool isTr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppColors.yellow,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isTr ? 'Premium Gerekli' : 'Premium Required',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isTr
                  ? 'Normal kullanıcılar en fazla 10 favori element ekleyebilir.'
                  : 'Regular users can add up to 10 favorite elements.',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isTr
                  ? 'Premium olarak sınırsız favori ekleyebilirsiniz!'
                  : 'With Premium, you can add unlimited favorites!',
              style: TextStyle(
                color: AppColors.yellow.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isTr ? 'İptal' : 'Cancel',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isTr ? 'Premium Ol' : 'Go Premium',
              style: const TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsCards(BuildContext context, Color elementColor) {
    final isTr = Provider.of<LocalizationProvider>(context).isTr;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            isTr ? 'Ağırlık' : 'Weight',
            _formatWeight(widget.element.weight),
            Icons.scale,
            elementColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            isTr ? 'Grup' : 'Group',
            widget.element.group ?? '',
            Icons.group_work,
            elementColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            isTr ? 'Periyot' : 'Period',
            widget.element.period ?? '',
            Icons.timeline,
            elementColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(BuildContext context, Color elementColor) {
    final isTr = Provider.of<LocalizationProvider>(context).isTr;
    final tabs = [
      isTr ? 'Genel Bakış' : 'Overview',
      isTr ? 'Özellikler' : 'Properties',
      isTr ? 'Detaylar' : 'Details',
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: elementColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _currentTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSelected ? elementColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: context.textTheme.titleSmall?.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.white.withValues(alpha: 0.7),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, Color elementColor, bool isTr) {
    switch (_currentTabIndex) {
      case 0:
        return _buildOverviewTab(context, elementColor, isTr);
      case 1:
        return _buildPropertiesTab(context, elementColor, isTr);
      case 2:
        return _buildDetailsTab(context, elementColor, isTr);
      default:
        return _buildOverviewTab(context, elementColor, isTr);
    }
  }

  Widget _buildOverviewTab(
    BuildContext context,
    Color elementColor,
    bool isTr,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          context,
          isTr ? 'Açıklama' : 'Description',
          isTr
              ? widget.element.trDescription ?? ''
              : widget.element.enDescription ?? '',
          Icons.info_outline,
          elementColor,
        ),
        const SizedBox(height: 20),
        _buildInfoSection(
          context,
          isTr ? 'Kullanım Alanları' : 'Applications',
          isTr ? widget.element.trUsage ?? '' : widget.element.enUsage ?? '',
          Icons.science,
          elementColor,
        ),
        const SizedBox(height: 20),
        _buildInfoSection(
          context,
          isTr ? 'Kaynak' : 'Source',
          isTr ? widget.element.trSource ?? '' : widget.element.enSource ?? '',
          Icons.source,
          elementColor,
        ),
      ],
    );
  }

  Widget _buildPropertiesTab(
    BuildContext context,
    Color elementColor,
    bool isTr,
  ) {
    return Column(
      children: [
        // Electron Configuration Visualization
        ElectronConfigurationWidget(element: widget.element),
        const SizedBox(height: 20),
        // Electron Configuration Text
        _buildElectronConfigurationText(context, elementColor, isTr),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context, Color elementColor, bool isTr) {
    return Column(
      children: [
        _buildDetailCard(
          context,
          isTr ? 'Fiziksel Özellikler' : 'Physical Properties',
          [
            DetailItem.highlighted(
              label: isTr ? 'Atom Numarası' : 'Atomic Number',
              value: widget.element.number?.toString() ?? '',
              icon: Icons.tag,
            ),
            DetailItem.withUnit(
              label: isTr ? 'Atom Ağırlığı' : 'Atomic Weight',
              value: _formatWeight(widget.element.weight),
              unit: 'u',
              icon: Icons.scale,
            ),
          ],
          Icons.science_outlined,
          elementColor,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          context,
          isTr ? 'Kimyasal Özellikler' : 'Chemical Properties',
          [
            DetailItem.withUnit(
              label: isTr ? 'Elektronegatiflik' : 'Electronegativity',
              value: widget.element.electronegativity?.toString() ?? '-',
              unit: '',
              svgPath: AssetConstants.instance.svgThunder,
            ),
            DetailItem.withUnit(
              label: isTr ? 'Atom Yarıçapı' : 'Atomic Radius',
              value: widget.element.atomicRadius?.toString() ?? '-',
              unit: 'pm',
              svgPath: AssetConstants.instance.svgRadius,
            ),
          ],
          Icons.science,
          elementColor,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          context,
          isTr ? 'Sınıflandırma' : 'Classification',
          [
            DetailItem(
              label: isTr ? 'Blok' : 'Block',
              value: widget.element.block ?? '',
              icon: Icons.crop_square,
            ),
            DetailItem(
              label: isTr ? 'Periyot' : 'Period',
              value: widget.element.period ?? '',
              icon: Icons.timeline,
            ),
            DetailItem(
              label: isTr ? 'Grup' : 'Group',
              value: widget.element.group ?? '',
              icon: Icons.group_work,
            ),
            DetailItem(
              label: isTr ? 'Kategori' : 'Category',
              value: isTr
                  ? widget.element.trCategory ?? ''
                  : widget.element.enCategory ?? '',
              icon: Icons.category,
            ),
          ],
          Icons.tune,
          elementColor,
        ),
      ],
    );
  }

  Widget _buildElectronConfigurationText(
    BuildContext context,
    Color elementColor,
    bool isTr,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor.withValues(alpha: 0.15),
            elementColor.withValues(alpha: 0.12),
            elementColor.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: elementColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: elementColor.withValues(alpha: 0.2),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science_outlined,
                color: elementColor.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isTr ? 'Elektron Konfigürasyonu' : 'Electron Configuration',
                style: TextStyle(
                  color: elementColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.element.electronConfiguration ?? '-',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String title,
    List<DetailItem> details,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...details
              .map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      if (detail.icon != null) ...[
                        Icon(
                          detail.icon,
                          color: color.withValues(alpha: 0.7),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ] else if (detail.svgPath != null) ...[
                        SvgPicture.asset(
                          detail.svgPath!,
                          colorFilter: ColorFilter.mode(
                            color.withValues(alpha: 0.7),
                            BlendMode.srcIn,
                          ),
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        flex: 2,
                        child: Text(
                          detail.label,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: detail.isHighlighted
                                ? AppColors.white
                                : AppColors.white.withValues(alpha: 0.7),
                            fontWeight: detail.isHighlighted
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          detail.displayValue,
                          textAlign: TextAlign.end,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: detail.valueColor ?? AppColors.white,
                            fontWeight: detail.isHighlighted
                                ? FontWeight.w900
                                : FontWeight.bold,
                            fontSize: detail.isHighlighted ? 16 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

// Removed old pattern painter; unified with PatternService

import 'package:elements_app/core/painter/element_particles_painter.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/favorite_elements_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Data class for detail card items
class DetailItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool isHighlighted;
  final String? unit;

  const DetailItem({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.isHighlighted = false,
    this.unit,
  });

  /// Creates a DetailItem with a highlighted value
  const DetailItem.highlighted({
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.unit,
  }) : isHighlighted = true;

  /// Creates a DetailItem with a unit
  const DetailItem.withUnit({
    required this.label,
    required this.value,
    required this.unit,
    this.icon,
    this.valueColor,
    this.isHighlighted = false,
  });

  /// Gets the display value with unit if available
  String get displayValue => unit != null ? '$value $unit' : value;
}

class ElementDetailView extends StatefulWidget {
  final PeriodicElement element;
  const ElementDetailView({
    super.key,
    required this.element,
  });

  @override
  State<ElementDetailView> createState() => _ElementDetailViewState();
}

class _ElementDetailViewState extends State<ElementDetailView>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

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
      return doubleValue.toStringAsFixed(4);
    }

    // If parsing fails, return original value
    return weight;
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
        body: CustomScrollView(
          slivers: [
            // Modern Hero Header
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: elementColor,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroHeader(context, elementColor, isTr),
              ),
              leading: const BackButton(),
              actions: _buildActionButtons(elementColor),
            ),

            // Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Quick Stats Cards
                          _buildQuickStatsCards(context, elementColor),
                          const SizedBox(height: 24),

                          // Tab Navigation
                          _buildTabNavigation(context, elementColor),
                          const SizedBox(height: 20),

                          // Tab Content - Integrated into main scroll
                          _buildTabContent(context, elementColor, isTr),

                          const SizedBox(height: 100), // Bottom padding for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Quiz functionality removed
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, Color elementColor, bool isTr) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor,
            elementColor.withValues(alpha: 0.8),
            elementColor.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated background particles
          Positioned.fill(
            child: CustomPaint(
              painter: ElementParticlesPainter(elementColor),
            ),
          ),

          // Main content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Element symbol and number
                  Row(
                    children: [
                      // Element number
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.element.number?.toString() ?? '',
                            style: context.textTheme.headlineLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Element symbol and name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.element.symbol ?? '',
                              style: context.textTheme.displayMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTr
                                  ? widget.element.trName ?? ''
                                  : widget.element.enName ?? '',
                              style: context.textTheme.headlineSmall?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      isTr
                          ? widget.element.trCategory?.toUpperCase() ?? ''
                          : widget.element.enCategory?.toUpperCase() ?? '',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(Color elementColor) {
    return [
      Consumer<FavoriteElementsProvider>(
        builder: (context, provider, child) {
          final isFavorite = provider.isFavorite(widget.element);
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
                provider.toggleFavorite(widget.element);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.read<LocalizationProvider>().isTr
                          ? isFavorite
                              ? 'Favorilerden kaldırıldı'
                              : 'Favorilere eklendi'
                          : isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites',
                    ),
                    backgroundColor: elementColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.share, color: AppColors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.element.symbol} paylaşıldı!'),
                backgroundColor: elementColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildQuickStatsCards(BuildContext context, Color elementColor) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Ağırlık',
            _formatWeight(widget.element.weight),
            Icons.scale,
            elementColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Grup',
            widget.element.group ?? '',
            Icons.group_work,
            elementColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Periyot',
            widget.element.period ?? '',
            Icons.timeline,
            elementColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
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
          Icon(
            icon,
            color: color,
            size: 24,
          ),
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
    final tabs = ['Genel Bakış', 'Özellikler', 'Detaylar'];

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
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
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
      BuildContext context, Color elementColor, bool isTr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          context,
          'Açıklama',
          isTr
              ? widget.element.trDescription ?? ''
              : widget.element.enDescription ?? '',
          Icons.info_outline,
          elementColor,
        ),
        const SizedBox(height: 20),
        _buildInfoSection(
          context,
          'Kullanım Alanları',
          isTr ? widget.element.trUsage ?? '' : widget.element.enUsage ?? '',
          Icons.science,
          elementColor,
        ),
      ],
    );
  }

  Widget _buildPropertiesTab(
      BuildContext context, Color elementColor, bool isTr) {
    return Column(
      children: [
        _buildPropertyGrid(context, elementColor),
        const SizedBox(height: 20),
        _buildInfoSection(
          context,
          'Kaynak',
          isTr ? widget.element.trSource ?? '' : widget.element.enSource ?? '',
          Icons.source,
          elementColor,
        ),
      ],
    );
  }

  Widget _buildDetailsTab(BuildContext context, Color elementColor, bool isTr) {
    return Column(
      children: [
        _buildDetailCard(
          context,
          'Fiziksel Özellikler',
          [
            DetailItem.highlighted(
                label: 'Atom Numarası',
                value: widget.element.number?.toString() ?? '',
                icon: Icons.tag),
            DetailItem.withUnit(
                label: 'Atom Ağırlığı',
                value: _formatWeight(widget.element.weight),
                unit: 'u',
                icon: Icons.scale),
            DetailItem(
                label: 'Elektron Konfigürasyonu',
                value: widget.element.electronConfiguration ?? '-',
                icon: Icons.science_outlined,
                valueColor: widget.element.electronConfiguration != null
                    ? null
                    : AppColors.white.withValues(alpha: 0.5)),
          ],
          Icons.science_outlined,
          elementColor,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          context,
          'Kimyasal Özellikler',
          [
            const DetailItem.withUnit(
                label: 'Elektronegatiflik',
                value: '2.20',
                unit: '',
                icon: Icons.electric_bolt),
            const DetailItem.withUnit(
                label: 'İyonlaşma Enerjisi',
                value: '1312',
                unit: 'kJ/mol',
                icon: Icons.flash_on),
            const DetailItem.withUnit(
                label: 'Atom Yarıçapı',
                value: '120',
                unit: 'pm',
                icon: Icons.radio_button_unchecked),
          ],
          Icons.science,
          elementColor,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          context,
          'Sınıflandırma',
          [
            DetailItem(
                label: 'Blok',
                value: widget.element.block ?? '',
                icon: Icons.crop_square),
            DetailItem(
                label: 'Periyot',
                value: widget.element.period ?? '',
                icon: Icons.timeline),
            DetailItem(
                label: 'Grup',
                value: widget.element.group ?? '',
                icon: Icons.group_work),
            DetailItem(
                label: 'Kategori',
                value: isTr
                    ? widget.element.trCategory ?? ''
                    : widget.element.enCategory ?? '',
                icon: Icons.category),
          ],
          Icons.tune,
          elementColor,
        ),
      ],
    );
  }

  Widget _buildPropertyGrid(BuildContext context, Color elementColor) {
    final properties = [
      DetailItem(
          label: 'Blok',
          value: widget.element.block ?? '',
          icon: Icons.crop_square),
      DetailItem(
          label: 'Periyot',
          value: widget.element.period ?? '',
          icon: Icons.timeline),
      DetailItem(
          label: 'Grup',
          value: widget.element.group ?? '',
          icon: Icons.group_work),
      DetailItem(
          label: 'Kategori',
          value: widget.element.enCategory ?? '',
          icon: Icons.category),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: elementColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: elementColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Temel Özellikler',
                style: context.textTheme.titleLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 400 ? 2 : 1,
                  childAspectRatio: constraints.maxWidth > 400 ? 3 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return _buildPropertyItem(
                    context,
                    property.label,
                    property.value,
                    property.icon ?? Icons.info,
                    elementColor,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content,
      IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
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

  Widget _buildDetailCard(BuildContext context, String title,
      List<DetailItem> details, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
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
              .map((detail) => Padding(
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
                  ))
              .toList(),
        ],
      ),
    );
  }
}

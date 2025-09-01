import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elementColor = widget.element.colors?.toColor() ?? AppColors.darkBlue;
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
              leading: _buildBackButton(elementColor),
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

        // Modern Floating Action Button
        floatingActionButton: _buildModernFAB(context, elementColor),
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

  Widget _buildBackButton(Color elementColor) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  List<Widget> _buildActionButtons(Color elementColor) {
    return [
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Favorilere eklendi!'),
                backgroundColor: elementColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
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
            widget.element.weight ?? '',
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
            {
              'label': 'Atom Numarası',
              'value': widget.element.number?.toString() ?? ''
            },
            {'label': 'Atom Ağırlığı', 'value': widget.element.weight ?? ''},
            {
              'label': 'Elektron Konfigürasyonu',
              'value': widget.element.electronConfiguration ?? ""
            },
          ],
          Icons.science_outlined,
          elementColor,
        ),
        const SizedBox(height: 16),
        _buildDetailCard(
          context,
          'Kimyasal Özellikler',
          [
            {'label': 'Elektronegatiflik', 'value': '2.20'},
            {'label': 'İyonlaşma Enerjisi', 'value': '1312 kJ/mol'},
            {'label': 'Atom Yarıçapı', 'value': '120 pm'},
          ],
          Icons.science,
          elementColor,
        ),
      ],
    );
  }

  Widget _buildPropertyGrid(BuildContext context, Color elementColor) {
    final properties = [
      {
        'label': 'Blok',
        'value': widget.element.block ?? '',
        'icon': Icons.crop_square
      },
      {
        'label': 'Periyot',
        'value': widget.element.period ?? '',
        'icon': Icons.timeline
      },
      {
        'label': 'Grup',
        'value': widget.element.group ?? '',
        'icon': Icons.group_work
      },
      {
        'label': 'Kategori',
        'value': widget.element.enCategory ?? '',
        'icon': Icons.category
      },
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyItem(
                context,
                property['label'] as String,
                property['value'] as String,
                property['icon'] as IconData,
                elementColor,
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
      padding: const EdgeInsets.all(12),
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
          const SizedBox(width: 8),
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
                ),
                Text(
                  value,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
      List<Map<String, String>> details, IconData icon, Color color) {
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
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            detail['label']!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            detail['value']!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
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

  Widget _buildModernFAB(BuildContext context, Color elementColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [elementColor, elementColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: elementColor.withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          // Quiz başlat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.element.symbol} quiz\'i başlatılıyor...'),
              backgroundColor: elementColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.quiz, color: AppColors.white),
        label: Text(
          'Quiz Başlat',
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ElementParticlesPainter extends CustomPainter {
  final Color color;

  ElementParticlesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2;

    // Draw animated particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    // Draw connecting lines
    for (int i = 0; i < 10; i++) {
      final x1 = (i * 67) % size.width;
      final y1 = (i * 41) % size.height;
      final x2 = ((i + 1) * 67) % size.width;
      final y2 = ((i + 1) * 41) % size.height;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

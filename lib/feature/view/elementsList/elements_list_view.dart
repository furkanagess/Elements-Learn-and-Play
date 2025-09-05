import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/mixin/elementList/elements_list_view_mixin.dart';
import 'package:elements_app/feature/view/quiz/modern_quiz_home.dart';

import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:elements_app/product/widget/loadingBar/loading_bar.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ElementsListView extends StatefulWidget {
  final String apiType;
  final String title;
  const ElementsListView({
    super.key,
    required this.apiType,
    required this.title,
  });

  @override
  State<ElementsListView> createState() => _ElementsListViewState();
}

class _ElementsListViewState extends State<ElementsListView>
    with TickerProviderStateMixin, ElementsListViewMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<PeriodicElement> _filteredElements = [];
  bool _isGridView = false;
  String _searchQuery = '';
  bool _showSearchBar = false;

  late AnimationController _mainAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScrollChanged);

    _mainAnimationController = AnimationController(
      duration:
          const Duration(milliseconds: 400), // Animasyon süresini kısalttık
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.3, // Başlangıç opaklığını artırdık
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.4,
          curve: Curves.easeOut), // Interval'i kısalttık
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Başlangıç offset'ini azalttık
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.4,
          curve: Curves.easeOutCubic), // Interval'i kısalttık
    ));

    // Animasyonu hemen başlatıyoruz
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _mainAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _onScrollChanged() {
    final scrollOffset = _scrollController.offset;
    final shouldShowSearchBar = scrollOffset > 100;

    if (shouldShowSearchBar != _showSearchBar) {
      setState(() {
        _showSearchBar = shouldShowSearchBar;
      });
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
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
    // Loading durumunu daha akıcı yönetiyoruz
    if (isLoading) {
      _mainAnimationController.forward(); // Loading sırasında animasyonu başlat
      return const AppScaffold(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: ComprehensiveLoadingBar(
            loadingText: 'Elementler yükleniyor...',
          ),
        ),
      );
    }

    return AppScaffold(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Navigator.pop(context);
          },
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern Hero Header with Search
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.darkBlue,
                systemOverlayStyle: SystemUiOverlayStyle.light,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeroHeader(context),
                ),
                title: _showSearchBar ? _buildSearchBar() : null,
                leading: _buildBackButton(),
                actions: _buildActionButtons(),
              ),

              // Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FutureBuilder<List<PeriodicElement>>(
                      future: elementList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          _mainAnimationController
                              .forward(); // Loading sırasında animasyonu başlat
                          return Container(); // Boş container döndürüyoruz çünkü ana loading zaten gösteriliyor
                        } else {
                          final elements = snapshot.data ?? [];
                          _filteredElements = _filterElements(elements);

                          if (_filteredElements.isEmpty &&
                              _searchQuery.isNotEmpty) {
                            return _buildEmptySearchState();
                          }

                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // View Mode Toggle
                                _buildViewModeToggle(),
                                const SizedBox(height: 20),

                                // Elements Grid/List
                                _isGridView
                                    ? _buildModernGridView(_filteredElements)
                                    : _buildModernListView(_filteredElements),

                                const SizedBox(height: 100), // Bottom padding
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Modern Floating Action Button
          floatingActionButton: _buildModernFAB(context),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBlue, AppColors.background],
          stops: [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: ElementsListPatternPainter(),
            ),
          ),

          // Main content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: SvgPicture.asset(
                          AssetConstants.instance.svgElementGroup,
                          colorFilter: const ColorFilter.mode(
                              AppColors.white, BlendMode.srcIn),
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<List<PeriodicElement>>(
                              future: elementList,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final elements = snapshot.data ?? [];
                                  final filteredElements =
                                      _filterElements(elements);
                                  return Text(
                                    '${filteredElements.length} element',
                                    style:
                                        context.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.white
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                } else {
                                  return Text(
                                    '0 element',
                                    style:
                                        context.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.white
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
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
    );
  }

  Widget _buildBackButton() {
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

  List<Widget> _buildActionButtons() {
    return [
      Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.filter_list, color: AppColors.white),
          onPressed: () {
            _showFilterModal(context);
          },
        ),
      ),
    ];
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              context.read<LocalizationProvider>().isTr
                  ? 'Sıralama Seçenekleri'
                  : 'Sort Options',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Filter Options
            _buildFilterOption(
              context,
              icon: Icons.format_list_numbered,
              title: context.read<LocalizationProvider>().isTr
                  ? 'Atom Numarasına Göre'
                  : 'By Atomic Number',
              onTap: () {
                _sortElements('number');
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              context,
              icon: Icons.sort_by_alpha,
              title: context.read<LocalizationProvider>().isTr
                  ? 'İsme Göre'
                  : 'By Name',
              onTap: () {
                _sortElements('name');
                Navigator.pop(context);
              },
            ),
            _buildFilterOption(
              context,
              icon: Icons.scale,
              title: context.read<LocalizationProvider>().isTr
                  ? 'Atom Ağırlığına Göre'
                  : 'By Atomic Weight',
              onTap: () {
                _sortElements('weight');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortElements(String criteria) {
    setState(() {
      switch (criteria) {
        case 'number':
          _filteredElements
              .sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));
          break;
        case 'name':
          _filteredElements.sort((a, b) {
            final aName = context.read<LocalizationProvider>().isTr
                ? (a.trName ?? '')
                : (a.enName ?? '');
            final bName = context.read<LocalizationProvider>().isTr
                ? (b.trName ?? '')
                : (b.enName ?? '');
            return aName.compareTo(bName);
          });
          break;
        case 'weight':
          _filteredElements.sort((a, b) {
            final aWeight =
                double.tryParse(a.weight?.replaceAll(',', '.') ?? '0') ?? 0;
            final bWeight =
                double.tryParse(b.weight?.replaceAll(',', '.') ?? '0') ?? 0;
            return aWeight.compareTo(bWeight);
          });
          break;
      }
    });
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            height: 1,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: context.read<LocalizationProvider>().isTr
                ? 'Element adı, sembol veya numara ara...'
                : 'Search by element name, symbol or number...',
            hintStyle: TextStyle(
              color: AppColors.white.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.search,
                color: AppColors.white.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Column(
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.glowGreen.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_isGridView) {
                      _toggleViewMode();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: !_isGridView
                          ? AppColors.glowGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_list,
                            color: !_isGridView
                                ? AppColors.darkBlue
                                : AppColors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Liste',
                            style: TextStyle(
                              color: !_isGridView
                                  ? AppColors.darkBlue
                                  : AppColors.white.withValues(alpha: 0.7),
                              fontWeight: !_isGridView
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!_isGridView) {
                      _toggleViewMode();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: _isGridView
                          ? AppColors.glowGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grid_view,
                            color: _isGridView
                                ? AppColors.darkBlue
                                : AppColors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Grid',
                            style: TextStyle(
                              color: _isGridView
                                  ? AppColors.darkBlue
                                  : AppColors.white.withValues(alpha: 0.7),
                              fontWeight: _isGridView
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Banner Ads
        const BannerAdsWidget(
          margin: EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  Widget _buildEmptySearchState() {
    final isTr = context.read<LocalizationProvider>().isTr;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated search illustration
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.glowGreen.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.glowGreen.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: EmptyStatePatternPainter(),
                  ),
                ),
                // Lottie animation
                Positioned.fill(
                  child: Lottie.asset(
                    AssetConstants.instance.lottieSearch,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildModernListView(List<PeriodicElement> elements) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return _buildModernListCard(element, index);
      },
    );
  }

  Widget _buildModernListCard(PeriodicElement element, int index) {
    Color elementColor;
    Color shadowColor;

    try {
      if (element.colors is String) {
        elementColor = (element.colors as String).toColor();
      } else if (element.colors != null) {
        elementColor = element.colors!.toColor();
      } else {
        elementColor = AppColors.darkBlue;
      }

      if (element.shColor is String) {
        shadowColor = (element.shColor as String).toColor();
      } else if (element.shColor != null) {
        shadowColor = element.shColor!.toColor();
      } else {
        shadowColor = AppColors.background;
      }
    } catch (e) {
      elementColor = AppColors.darkBlue;
      shadowColor = AppColors.background;
    }

    final isTr = Provider.of<LocalizationProvider>(context, listen: false).isTr;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor,
            elementColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElementDetailView(element: element),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Element number
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      element.number?.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Element info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element.symbol ?? '',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTr ? element.trName ?? '' : element.enName ?? '',
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
                        _formatWeight(element.weight),
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernGridView(List<PeriodicElement> elements) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return _buildModernGridCard(element, index);
      },
    );
  }

  Widget _buildModernGridCard(PeriodicElement element, int index) {
    Color elementColor;
    Color shadowColor;

    try {
      if (element.colors is String) {
        elementColor = (element.colors as String).toColor();
      } else if (element.colors != null) {
        elementColor = element.colors!.toColor();
      } else {
        elementColor = AppColors.darkBlue;
      }

      if (element.shColor is String) {
        shadowColor = (element.shColor as String).toColor();
      } else if (element.shColor != null) {
        shadowColor = element.shColor!.toColor();
      } else {
        shadowColor = AppColors.background;
      }
    } catch (e) {
      elementColor = AppColors.darkBlue;
      shadowColor = AppColors.background;
    }

    final isTr = Provider.of<LocalizationProvider>(context, listen: false).isTr;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            elementColor,
            elementColor.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ElementDetailView(element: element),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Element number
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      element.number?.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Element symbol
                Text(
                  element.symbol ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),

                // Element name
                Text(
                  isTr ? element.trName ?? '' : element.enName ?? '',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Element weight
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatWeight(element.weight),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.glowGreen, AppColors.darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowGreen.withValues(alpha: 0.4),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModernQuizHome(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: SvgPicture.asset(
          AssetConstants.instance.svgGameThree,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          width: 24,
          height: 24,
        ),
        label: const Text(
          'Quiz Başlat',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  List<PeriodicElement> _filterElements(List<PeriodicElement> elements) {
    if (_searchQuery.isEmpty) {
      return elements;
    }

    final query = _searchQuery.toLowerCase();
    return elements.where((element) {
      final name = context.read<LocalizationProvider>().isTr
          ? element.trName?.toLowerCase() ?? ''
          : element.enName?.toLowerCase() ?? '';
      final symbol = element.symbol?.toLowerCase() ?? '';
      final number = element.number?.toString() ?? '';

      return name.contains(query) ||
          symbol.contains(query) ||
          number.contains(query);
    }).toList();
  }
}

class ElementsListPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Draw subtle pattern
    for (int i = 0; i < size.width; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    for (int i = 0; i < size.height; i += 40) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Draw some circles for visual interest
    final circlePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = (i * 80) % size.width;
      final y = (i * 60) % size.height;
      canvas.drawCircle(Offset(x, y), 20, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmptyStatePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw a modern geometric pattern
    final path = Path();

    // Draw diagonal lines
    for (int i = 0; i < size.width + size.height; i += 40) {
      path.moveTo(i.toDouble(), 0);
      path.lineTo(0, i.toDouble());
    }

    // Draw circles at intersections
    for (int x = 0; x < size.width; x += 40) {
      for (int y = 0; y < size.height; y += 40) {
        canvas.drawCircle(
          Offset(x.toDouble(), y.toDouble()),
          2,
          paint..style = PaintingStyle.fill,
        );
      }
    }

    // Draw the pattern
    canvas.drawPath(path, paint..style = PaintingStyle.stroke);

    // Add some decorative elements
    final decorPaint = Paint()
      ..color = AppColors.glowGreen.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw glowing dots
    for (int i = 0; i < 5; i++) {
      final x = (i * 60) % size.width;
      final y = (i * 60) % size.height;

      // Draw outer glow
      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        8,
        decorPaint,
      );

      // Draw inner dot
      canvas.drawCircle(
        Offset(x.toDouble(), y.toDouble()),
        3,
        decorPaint..color = AppColors.glowGreen.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

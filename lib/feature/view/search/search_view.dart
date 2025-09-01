import 'dart:convert';

import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/quiz/symbol/quiz_symbol_view.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:elements_app/product/widget/loadingBar/loading_bar.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<PeriodicElement> _elements = [];
  List<PeriodicElement> _filteredElements = [];
  bool _isGridView = false;
  bool _isSearching = false;
  bool _isSearchFocused = false;
  bool _isLoading = true;
  bool _showSearchBar = false;

  late AnimationController _mainAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _searchScaleAnimation;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _scrollController.addListener(_onScrollChanged);

    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _searchScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadElements();
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _mainAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    final scrollOffset = _scrollController.offset;
    final shouldShowSearchBar =
        scrollOffset > 100; // SliverAppBar expandedHeight'ı geçince göster

    if (shouldShowSearchBar != _showSearchBar) {
      setState(() {
        _showSearchBar = shouldShowSearchBar;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _isSearching = _searchController.text.isNotEmpty;
    });
  }

  void _onSearchFocusChanged() {
    setState(() {
      _isSearchFocused = _searchFocusNode.hasFocus;
    });
    if (_isSearchFocused) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
    }
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  Future<void> _loadElements() async {
    try {
      final response = await http.get(Uri.parse(ApiTypes.allElements));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _elements =
              data.map((element) => PeriodicElement.fromJson(element)).toList();
          _filteredElements = List.from(_elements);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load elements');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<PeriodicElement> _filterElements(List<PeriodicElement> elements) {
    if (_searchController.text.isEmpty) {
      return elements;
    }

    final query = _searchController.text.toLowerCase();
    final isTr = Provider.of<LocalizationProvider>(context, listen: false).isTr;

    return elements.where((element) {
      final name = isTr ? element.trName ?? '' : element.enName ?? '';
      final symbol = element.symbol ?? '';
      final number = element.number?.toString() ?? '';

      return name.toLowerCase().contains(query) ||
          symbol.toLowerCase().contains(query) ||
          number.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Modern Hero Header
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
              leading: _buildBackButton(),
              title: _showSearchBar ? _buildSearchBar() : null,
              actions: _buildActionButtons(),
            ),

            // Content
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _isLoading ? const LoadingBar() : _buildContent(),
                ),
              ),
            ),
          ],
        ),

        // Modern Floating Action Button
        floatingActionButton: _buildModernFAB(context),
      ),
    );
  }

  Widget _buildContent() {
    final filteredElements = _filterElements(_elements);

    if (filteredElements.isEmpty && _isSearching) {
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
              ? _buildModernGridView(filteredElements)
              : _buildModernListView(filteredElements),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue,
            AppColors.darkBlue.withValues(alpha: 0.8),
            AppColors.darkBlue.withValues(alpha: 0.6),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: ElementsListPatternPainter(AppColors.darkBlue),
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
                          AssetConstants.instance.svgScienceTwo,
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
                              Provider.of<LocalizationProvider>(context,
                                          listen: false)
                                      .isTr
                                  ? TrAppStrings.allElements
                                  : EnAppStrings.elements,
                              style: context.textTheme.headlineLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_elements.length} Element',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
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
            // Filter functionality
          },
        ),
      ),
    ];
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _searchScaleAnimation.value,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isSearchFocused
                    ? AppColors.turquoise
                    : AppColors.white.withValues(alpha: 0.3),
                width: _isSearchFocused ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isSearchFocused
                      ? AppColors.turquoise.withValues(alpha: 0.2)
                      : AppColors.darkBlue.withValues(alpha: 0.1),
                  offset: const Offset(0, 4),
                  blurRadius: _isSearchFocused ? 12 : 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Search Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isSearchFocused
                        ? AppColors.turquoise.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: _isSearchFocused
                        ? AppColors.turquoise
                        : AppColors.darkBlue.withValues(alpha: 0.6),
                    size: 22,
                  ),
                ),

                // Text Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: const TextStyle(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: Provider.of<LocalizationProvider>(context,
                                  listen: false)
                              .isTr
                          ? 'Element ara...'
                          : 'Search elements...',
                      hintStyle: TextStyle(
                        color: AppColors.darkBlue.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),

                // Clear Button
                if (_isSearching)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.powderRed.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.powderRed,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isGridView = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color:
                      !_isGridView ? AppColors.turquoise : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Icon(
                    Icons.view_list,
                    color: !_isGridView
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isGridView = true;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _isGridView ? AppColors.turquoise : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Icon(
                    Icons.grid_view,
                    color: _isGridView
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            AssetConstants.instance.lottieSearch,
            height: 200,
            repeat: true,
          ),
          const SizedBox(height: 24),
          Text(
            Provider.of<LocalizationProvider>(context, listen: false).isTr
                ? 'Aradığınız element bulunamadı'
                : 'Element not found',
            style: context.textTheme.headlineSmall?.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            Provider.of<LocalizationProvider>(context, listen: false).isTr
                ? 'Farklı bir arama terimi deneyin'
                : 'Try a different search term',
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.darkBlue.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
            },
            icon: const Icon(Icons.clear),
            label: Text(
              Provider.of<LocalizationProvider>(context, listen: false).isTr
                  ? 'Aramayı Temizle'
                  : 'Clear Search',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.turquoise,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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
    final elementColor = element.colors?.toColor() ?? AppColors.darkBlue;
    final shadowColor = element.shColor?.toColor() ?? AppColors.background;
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
            context.read<AdmobProvider>().onRouteChanged();
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
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      element.number?.toString() ?? '',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

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
                          fontSize: 24,
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        element.weight ?? '',
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
                  color: AppColors.white.withValues(alpha: 0.6),
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
    final elementColor = element.colors?.toColor() ?? AppColors.darkBlue;
    final shadowColor = element.shColor?.toColor() ?? AppColors.background;
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
            context.read<AdmobProvider>().onRouteChanged();
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
                Text(
                  element.weight ?? '',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
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
        gradient: LinearGradient(
          colors: [
            AppColors.turquoise,
            AppColors.turquoise.withValues(alpha: 0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.turquoise.withValues(alpha: 0.4),
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
              builder: (context) => const QuizSymbolView(
                apiType: ApiTypes.allElements,
                title: TrAppStrings.allElements,
              ),
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
        label: Text(
          Provider.of<LocalizationProvider>(context, listen: false).isTr
              ? 'Quiz Başlat'
              : 'Start Quiz',
          style: context.textTheme.titleMedium?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ElementsListPatternPainter extends CustomPainter {
  final Color color;

  ElementsListPatternPainter(this.color);

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

import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/skeleton/element_card_skeleton.dart';
import 'package:elements_app/product/widget/card/element_card.dart';
import 'package:elements_app/feature/view/elementsList/widget/elements_grid_view.dart';
import 'package:elements_app/feature/view/elementsList/widget/elements_list_app_bar.dart';
import 'package:elements_app/feature/view/elementsList/widget/view_mode_toggle.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';

/// Progressive loading view that shows skeleton cards while loading real data
class ElementsProgressiveLoadingView extends StatefulWidget {
  final String apiType;
  final String title;
  final Future<List<PeriodicElement>> elementList;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onFilterPressed;
  final bool isGridView;
  final VoidCallback onToggleViewMode;

  const ElementsProgressiveLoadingView({
    super.key,
    required this.apiType,
    required this.title,
    required this.elementList,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterPressed,
    required this.isGridView,
    required this.onToggleViewMode,
  });

  @override
  State<ElementsProgressiveLoadingView> createState() =>
      _ElementsProgressiveLoadingViewState();
}

class _ElementsProgressiveLoadingViewState
    extends State<ElementsProgressiveLoadingView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _showSkeleton = true;
  List<PeriodicElement> _loadedElements = [];
  bool _isLoading = false;

  // Pattern service for background patterns
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _loadElements();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadElements() async {
    // Prevent multiple simultaneous loads
    if (_isLoading) return;
    _isLoading = true;

    try {
      final elements = await widget.elementList;

      if (mounted) {
        setState(() {
          _loadedElements = elements;
        });

        // Start transition animation immediately
        _slideController.forward();

        // Hide skeleton after short delay for smooth transition
        await Future.delayed(const Duration(milliseconds: 200));

        if (mounted) {
          setState(() {
            _showSkeleton = false;
          });
          _fadeController.forward();
        }
      }
    } catch (e) {
      // Handle error - show skeleton for longer
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _showSkeleton = false;
        });
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ElementsListAppBar(
          searchController: widget.searchController,
          searchQuery: widget.searchQuery,
          onSearchChanged: widget.onSearchChanged,
          onClearSearch: widget.onClearSearch,
          onFilterPressed: widget.onFilterPressed,
        ),
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),

            // Main Content
            Column(
              children: [
                Expanded(
                  child: _showSkeleton
                      ? _buildSkeletonContent()
                      : _buildRealContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // View Mode Toggle Skeleton
            _buildViewModeToggleSkeleton(),
            const SizedBox(height: 20),

            // Elements skeleton
            widget.isGridView ? _buildGridSkeleton() : _buildListSkeleton(),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildRealContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // View Mode Toggle
                ViewModeToggle(
                  isGridView: widget.isGridView,
                  onToggle: widget.onToggleViewMode,
                ),
                const SizedBox(height: 20),

                // Elements Grid/List
                widget.isGridView
                    ? ElementsGridView(elements: _loadedElements)
                    : _buildElementsList(_loadedElements),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewModeToggleSkeleton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSkeleton() {
    return Column(
      children: List.generate(
        6,
        (index) =>
            ElementCardSkeleton(mode: ElementCardMode.list, index: index),
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ElementCardSkeleton(mode: ElementCardMode.grid, index: index);
      },
    );
  }

  Widget _buildElementsList(List<PeriodicElement> elements) {
    return Column(
      children: elements.map((element) {
        return ElementCard(
          element: element,
          mode: ElementCardMode.list,
          index: elements.indexOf(element),
        );
      }).toList(),
    );
  }
}

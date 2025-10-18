import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/skeleton/shimmer_effect.dart';
import 'package:elements_app/product/widget/card/element_card.dart';
import 'package:flutter/material.dart';

/// Skeleton loading component for element cards
class ElementCardSkeleton extends StatefulWidget {
  final ElementCardMode mode;
  final int index;

  const ElementCardSkeleton({
    super.key,
    required this.mode,
    required this.index,
  });

  @override
  State<ElementCardSkeleton> createState() => _ElementCardSkeletonState();
}

class _ElementCardSkeletonState extends State<ElementCardSkeleton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _getCardMargin(),
      decoration: _buildCardDecoration(),
      child: MultiColorShimmerEffect(child: _buildContent()),
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

  /// Build card decoration based on mode
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Build content based on mode
  Widget _buildContent() {
    switch (widget.mode) {
      case ElementCardMode.list:
        return _buildListSkeleton();
      case ElementCardMode.grid:
        return _buildGridSkeleton();
      case ElementCardMode.favorites:
        return _buildFavoritesSkeleton();
    }
  }

  /// Build list mode skeleton
  Widget _buildListSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Element symbol skeleton
          _buildElementSymbolSkeleton(),
          const SizedBox(width: 16),
          // Element info skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Element name skeleton
                _buildSkeletonBox(height: 18, width: 120),
                const SizedBox(height: 4),
                // Atomic number skeleton
                _buildSkeletonBox(height: 14, width: 100),
              ],
            ),
          ),
          // Arrow skeleton
          _buildSkeletonBox(height: 24, width: 24, isCircle: true),
        ],
      ),
    );
  }

  /// Build grid mode skeleton
  Widget _buildGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with symbol and atomic number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Element symbol skeleton
              _buildElementSymbolSkeleton(size: 36),
              // Atomic number skeleton
              _buildSkeletonBox(height: 12, width: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Element name and atomic weight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Element name skeleton
              Expanded(child: _buildSkeletonBox(height: 13, width: 80)),
              const SizedBox(width: 8),
              // Atomic weight skeleton
              _buildSkeletonBox(height: 11, width: 40),
            ],
          ),
        ],
      ),
    );
  }

  /// Build favorites mode skeleton
  Widget _buildFavoritesSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Element symbol skeleton
          _buildElementSymbolSkeleton(),
          const SizedBox(width: 16),
          // Element info skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Element name skeleton
                _buildSkeletonBox(height: 16, width: 100),
                const SizedBox(height: 4),
                // Atomic number skeleton
                _buildSkeletonBox(height: 14, width: 30),
              ],
            ),
          ),
          // Favorite button skeleton
          _buildSkeletonBox(height: 40, width: 40, isCircle: true),
        ],
      ),
    );
  }

  /// Build element symbol skeleton
  Widget _buildElementSymbolSkeleton({double size = 56}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  /// Build skeleton box
  Widget _buildSkeletonBox({
    required double height,
    required double width,
    bool isCircle = false,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(4),
      ),
    );
  }
}

/// Skeleton loading for elements list view
class ElementsListSkeleton extends StatelessWidget {
  final bool isGridView;
  final int itemCount;

  const ElementsListSkeleton({
    super.key,
    this.isGridView = false,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // View Mode Toggle Skeleton
            _buildViewModeToggleSkeleton(),
            const SizedBox(height: 20),

            // Elements skeleton
            isGridView ? _buildGridSkeleton() : _buildListSkeleton(),

            const SizedBox(height: 100), // Bottom padding
          ],
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
        itemCount,
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
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ElementCardSkeleton(mode: ElementCardMode.grid, index: index);
      },
    );
  }
}

/// Enhanced skeleton loading view for elements screen
class ElementsSkeletonLoadingView extends StatefulWidget {
  final bool isGridView;
  final int itemCount;

  const ElementsSkeletonLoadingView({
    super.key,
    this.isGridView = false,
    this.itemCount = 6,
  });

  @override
  State<ElementsSkeletonLoadingView> createState() =>
      _ElementsSkeletonLoadingViewState();
}

class _ElementsSkeletonLoadingViewState
    extends State<ElementsSkeletonLoadingView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildSkeletonAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ElementsListSkeleton(
          isGridView: widget.isGridView,
          itemCount: widget.itemCount,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSkeletonAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}

import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/skeleton/element_card_skeleton.dart';
import 'package:elements_app/product/widget/card/element_card.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';

/// Modern skeleton loading view for elements screen
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
    extends State<ElementsSkeletonLoadingView> {
  // Pattern service for background patterns
  final PatternService _patternService = PatternService();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
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
            SafeArea(
              child: Column(
                children: [
                  // App Bar Skeleton
                  _buildSkeletonAppBar(),

                  // Content with skeleton
                  Expanded(child: _buildSkeletonContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonAppBar() {
    return Container(
      height: kToolbarHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Back button skeleton
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 16),
            // Search field skeleton
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Filter button skeleton
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
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
        widget.itemCount,
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
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return ElementCardSkeleton(mode: ElementCardMode.grid, index: index);
      },
    );
  }
}

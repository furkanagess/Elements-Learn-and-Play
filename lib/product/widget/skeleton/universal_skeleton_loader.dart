import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/skeleton/shimmer_effect.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';

/// Universal skeleton loader for different content types
class UniversalSkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final int itemCount;
  final bool showAppBar;
  final String? title;

  const UniversalSkeletonLoader({
    super.key,
    required this.type,
    this.itemCount = 6,
    this.showAppBar = true,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar ? _buildSkeletonAppBar() : null,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: PatternService().getPatternPainter(
                type: PatternType.atomic,
                color: Colors.white,
                opacity: 0.03,
              ),
            ),
          ),

          // Main Content
          SafeArea(child: _buildSkeletonContent()),
        ],
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
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildSkeletonContent() {
    switch (type) {
      case SkeletonType.elementsList:
        return _buildElementsListSkeleton();
      case SkeletonType.elementsGrid:
        return _buildElementsGridSkeleton();
      case SkeletonType.infoCards:
        return _buildInfoCardsSkeleton();
      case SkeletonType.quiz:
        return _buildQuizSkeleton();
      case SkeletonType.periodicTable:
        return _buildPeriodicTableSkeleton();
      case SkeletonType.simple:
        return _buildSimpleSkeleton();
    }
  }

  Widget _buildElementsListSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // View Mode Toggle Skeleton
          _buildViewModeToggleSkeleton(),
          const SizedBox(height: 20),

          // Elements List Skeleton
          Column(
            children: List.generate(
              itemCount,
              (index) => _buildElementCardSkeleton(ElementCardMode.list, index),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildElementsGridSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // View Mode Toggle Skeleton
          _buildViewModeToggleSkeleton(),
          const SizedBox(height: 20),

          // Elements Grid Skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return _buildElementCardSkeleton(ElementCardMode.grid, index);
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCardsSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Info Cards Skeleton
          Column(
            children: List.generate(
              itemCount,
              (index) => _buildInfoCardSkeleton(index),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildQuizSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Quiz Question Skeleton
          _buildQuizQuestionSkeleton(),
          const SizedBox(height: 20),

          // Quiz Options Skeleton
          Column(
            children: List.generate(
              4,
              (index) => _buildQuizOptionSkeleton(index),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPeriodicTableSkeleton() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 1080,
                height: 660,
                child: Stack(
                  children: [
                    // Background grid skeleton
                    _buildGridSkeleton(),

                    // Elements skeleton - positioned like real periodic table
                    ..._buildPeriodicTableElementsSkeleton(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildBannerAdSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSkeleton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSkeletonBox(height: 100, width: 100, isCircle: true),
          const SizedBox(height: 20),
          _buildSkeletonBox(height: 20, width: 200),
          const SizedBox(height: 10),
          _buildSkeletonBox(height: 16, width: 150),
        ],
      ),
    );
  }

  Widget _buildViewModeToggleSkeleton() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildElementCardSkeleton(ElementCardMode mode, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: mode == ElementCardMode.list
              ? _buildListCardSkeleton()
              : _buildGridCardSkeleton(),
        ),
      ),
    );
  }

  Widget _buildListCardSkeleton() {
    return Row(
      children: [
        _buildSkeletonBox(height: 60, width: 60, isCircle: true),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSkeletonBox(height: 20, width: 120),
              const SizedBox(height: 8),
              _buildSkeletonBox(height: 16, width: 80),
              const SizedBox(height: 4),
              _buildSkeletonBox(height: 14, width: 100),
            ],
          ),
        ),
        _buildSkeletonBox(height: 40, width: 40, isCircle: true),
      ],
    );
  }

  Widget _buildGridCardSkeleton() {
    return Column(
      children: [
        _buildSkeletonBox(height: 60, width: 60, isCircle: true),
        const SizedBox(height: 12),
        _buildSkeletonBox(height: 16, width: 80),
        const SizedBox(height: 4),
        _buildSkeletonBox(height: 14, width: 60),
        const SizedBox(height: 8),
        _buildSkeletonBox(height: 12, width: 100),
      ],
    );
  }

  Widget _buildInfoCardSkeleton(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _buildSkeletonBox(height: 48, width: 48, isCircle: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(height: 18, width: 120),
                    const SizedBox(height: 8),
                    _buildSkeletonBox(height: 14, width: 100),
                  ],
                ),
              ),
              _buildSkeletonBox(height: 40, width: 40, isCircle: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizQuestionSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizOptionSkeleton(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return CustomPaint(
      painter: _GridSkeletonPainter(),
      size: const Size(1080, 660),
    );
  }

  List<Widget> _buildPeriodicTableElementsSkeleton() {
    // Periodic table element positions (simplified)
    final elementPositions = [
      // Row 1 (H, He)
      const Offset(0, 0), const Offset(60, 0),
      // Row 2 (Li, Be, B, C, N, O, F, Ne)
      const Offset(0, 60), const Offset(60, 60), const Offset(120, 60),
      const Offset(180, 60), const Offset(240, 60), const Offset(300, 60),
      const Offset(360, 60), const Offset(420, 60),
      // Row 3 (Na, Mg, Al, Si, P, S, Cl, Ar)
      const Offset(0, 120), const Offset(60, 120), const Offset(120, 120),
      const Offset(180, 120), const Offset(240, 120), const Offset(300, 120),
      const Offset(360, 120), const Offset(420, 120),
      // Row 4 (K, Ca, Sc, Ti, V, Cr, Mn, Fe, Co, Ni, Cu, Zn, Ga, Ge, As, Se, Br, Kr)
      const Offset(0, 180), const Offset(60, 180), const Offset(120, 180),
      const Offset(180, 180), const Offset(240, 180), const Offset(300, 180),
      const Offset(360, 180), const Offset(420, 180), const Offset(480, 180),
      const Offset(540, 180), const Offset(600, 180), const Offset(660, 180),
      const Offset(720, 180), const Offset(780, 180), const Offset(840, 180),
      const Offset(900, 180), const Offset(960, 180), const Offset(1020, 180),
      // Row 5 (Rb, Sr, Y, Zr, Nb, Mo, Tc, Ru, Rh, Pd, Ag, Cd, In, Sn, Sb, Te, I, Xe)
      const Offset(0, 240), const Offset(60, 240), const Offset(120, 240),
      const Offset(180, 240), const Offset(240, 240), const Offset(300, 240),
      const Offset(360, 240), const Offset(420, 240), const Offset(480, 240),
      const Offset(540, 240), const Offset(600, 240), const Offset(660, 240),
      const Offset(720, 240), const Offset(780, 240), const Offset(840, 240),
      const Offset(900, 240), const Offset(960, 240), const Offset(1020, 240),
      // Row 6 (Cs, Ba, La, Hf, Ta, W, Re, Os, Ir, Pt, Au, Hg, Tl, Pb, Bi, Po, At, Rn)
      const Offset(0, 300), const Offset(60, 300), const Offset(120, 300),
      const Offset(180, 300), const Offset(240, 300), const Offset(300, 300),
      const Offset(360, 300), const Offset(420, 300), const Offset(480, 300),
      const Offset(540, 300), const Offset(600, 300), const Offset(660, 300),
      const Offset(720, 300), const Offset(780, 300), const Offset(840, 300),
      const Offset(900, 300), const Offset(960, 300), const Offset(1020, 300),
      // Row 7 (Fr, Ra, Ac, Rf, Db, Sg, Bh, Hs, Mt, Ds, Rg, Cn, Nh, Fl, Mc, Lv, Ts, Og)
      const Offset(0, 360), const Offset(60, 360), const Offset(120, 360),
      const Offset(180, 360), const Offset(240, 360), const Offset(300, 360),
      const Offset(360, 360), const Offset(420, 360), const Offset(480, 360),
      const Offset(540, 360), const Offset(600, 360), const Offset(660, 360),
      const Offset(720, 360), const Offset(780, 360), const Offset(840, 360),
      const Offset(900, 360), const Offset(960, 360), const Offset(1020, 360),
    ];

    return elementPositions.map((position) {
      return Positioned(
        left: position.dx,
        top: position.dy,
        child: _buildElementTileSkeleton(),
      );
    }).toList();
  }

  Widget _buildElementTileSkeleton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBannerAdSkeleton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: MultiColorShimmerEffect(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

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

class _GridSkeletonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i <= 18; i++) {
      final x = i * 60.0;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (int i = 0; i <= 11; i++) {
      final y = i * 60.0;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Skeleton types for different content
enum SkeletonType {
  elementsList,
  elementsGrid,
  infoCards,
  quiz,
  periodicTable,
  simple,
}

/// Element card modes for skeleton
enum ElementCardMode { list, grid }

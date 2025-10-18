import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/card/element_card.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/skeleton/element_card_skeleton.dart';
import 'package:elements_app/product/widget/loadingBar/modern_loading_indicator.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Demo page to showcase the new loading system
class ElementsLoadingDemo extends StatefulWidget {
  const ElementsLoadingDemo({super.key});

  @override
  State<ElementsLoadingDemo> createState() => _ElementsLoadingDemoState();
}

class _ElementsLoadingDemoState extends State<ElementsLoadingDemo>
    with TickerProviderStateMixin {
  late AnimationController _demoController;
  late Animation<double> _demoAnimation;

  bool _showSkeleton = true;
  bool _showProgressive = false;
  bool _showModern = false;

  // Pattern service for background patterns
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _demoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _demoController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Loading System Demo'),
          backgroundColor: Colors.transparent,
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
            SafeArea(
              child: Column(
                children: [
                  // Demo Controls
                  _buildDemoControls(),

                  const SizedBox(height: 20),

                  // Demo Content
                  Expanded(child: _buildDemoContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoControls() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Loading System Demo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Skeleton Cards',
                  _showSkeleton,
                  () => _toggleDemo('skeleton'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDemoButton(
                  'Progressive',
                  _showProgressive,
                  () => _toggleDemo('progressive'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDemoButton(
                  'Modern',
                  _showModern,
                  () => _toggleDemo('modern'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.7),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDemoContent() {
    if (_showSkeleton) {
      return _buildSkeletonDemo();
    } else if (_showProgressive) {
      return _buildProgressiveDemo();
    } else if (_showModern) {
      return _buildModernDemo();
    } else {
      return const Center(
        child: Text(
          'Select a loading type to see the demo',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
  }

  Widget _buildSkeletonDemo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // List Skeleton
          const Text(
            'List View Skeleton',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              3,
              (index) =>
                  ElementCardSkeleton(mode: ElementCardMode.list, index: index),
            ),
          ),

          const SizedBox(height: 32),

          // Grid Skeleton
          const Text(
            'Grid View Skeleton',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return ElementCardSkeleton(
                mode: ElementCardMode.grid,
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressiveDemo() {
    return FadeTransition(
      opacity: _demoAnimation,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Progressive Loading Demo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Shows skeleton cards first, then transitions to real content',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDemo() {
    return const Center(
      child: ModernLoadingIndicator(
        loadingText: 'Loading Elements...',
        showProgress: true,
        progress: 0.7,
      ),
    );
  }

  void _toggleDemo(String type) {
    setState(() {
      _showSkeleton = type == 'skeleton';
      _showProgressive = type == 'progressive';
      _showModern = type == 'modern';
    });

    if (_showProgressive || _showModern) {
      _demoController.forward();
    } else {
      _demoController.reset();
    }
  }
}

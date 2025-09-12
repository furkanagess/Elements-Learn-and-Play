import 'package:elements_app/core/painter/home_pattern_painter.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/view/home/widgets/element_of_day_widget.dart';
import 'package:elements_app/feature/view/home/widgets/features_grid_widget.dart';
import 'package:elements_app/feature/view/home/widgets/hero_section_widget.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/navigation/app_bottom_navbar.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/ads/banner_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

final class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<StatefulWidget> {
  @override
  void initState() {
    super.initState();
    // Load elements when the home view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodicTableProvider>().loadElements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.expand(
          child: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: HomePatternPainter(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                ),
              ),

              // Main Content
              Positioned.fill(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 100,
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 20),

                              // Element of the Day Section
                              RepaintBoundary(child: ElementOfDayWidget()),

                              SizedBox(height: 20),

                              // Hero Image Section (Periodic Table)
                              RepaintBoundary(child: HeroSectionWidget()),

                              SizedBox(height: 20),

                              // Main Features Grid
                              RepaintBoundary(child: FeaturesGridWidget()),

                              SizedBox(height: 20),

                              SizedBox(height: 20),

                              // // Test Interstitial Ad Button (only in debug mode)
                              // if (kDebugMode)
                              //   RepaintBoundary(
                              //     child: Container(
                              //       margin: EdgeInsets.symmetric(horizontal: 8.0),
                              //       child: ElevatedButton.icon(
                              //         onPressed: () {
                              //           InterstitialAdManager.instance.showAdOnAction();
                              //         },
                              //         icon: Icon(Icons.ads_click),
                              //         label: Text('Test Interstitial Ad'),
                              //         style: ElevatedButton.styleFrom(
                              //           backgroundColor: Colors.orange,
                              //           foregroundColor: Colors.white,
                              //           padding: EdgeInsets.symmetric(vertical: 12),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bottom Navigation Bar
              const Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: RepaintBoundary(child: AppBottomNavBar()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

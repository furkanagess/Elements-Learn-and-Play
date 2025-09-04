import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/container/element_group_container.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetalGroupPatternPainter extends CustomPainter {
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

class MetalGroupView extends StatelessWidget {
  const MetalGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.purple,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.purple,
                          AppColors.purple.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: _buildHeader(context),
                  ),
                ),
                leading: _buildBackButton(context),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.transitionMetal
                          : EnAppStrings.transitionMetal,
                      color: AppColors.purple,
                      shadowColor: AppColors.shPurple,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementsListView(
                              apiType: ApiTypes.transitionMetal,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.transitionMetal
                                  : EnAppStrings.transitionMetal,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.postTransition
                          : EnAppStrings.postTransition,
                      color: AppColors.steelBlue,
                      shadowColor: AppColors.shSteelBlue,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementsListView(
                              apiType: ApiTypes.postTransition,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.postTransition
                                  : EnAppStrings.postTransition,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.alkaline
                          : EnAppStrings.alkaline,
                      color: AppColors.turquoise,
                      shadowColor: AppColors.shTurquoise,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementsListView(
                              apiType: ApiTypes.alkaliMetal,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.alkaline
                                  : EnAppStrings.alkaline,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.earthAlkaline
                          : EnAppStrings.earthAlkaline,
                      color: AppColors.yellow,
                      shadowColor: AppColors.shYellow,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementsListView(
                              apiType: ApiTypes.alkalineEarthMetal,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.earthAlkaline
                                  : EnAppStrings.earthAlkaline,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.lanthanides
                          : EnAppStrings.lanthanides,
                      color: AppColors.darkTurquoise,
                      shadowColor: AppColors.shDarkTurquoise,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementsListView(
                              apiType: ApiTypes.lanthanides,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.lanthanides
                                  : EnAppStrings.lanthanides,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.actinides
                          : EnAppStrings.actinides,
                      color: AppColors.pink,
                      shadowColor: AppColors.shPink,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementsListView(
                              apiType: ApiTypes.actinides,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.actinides
                                  : EnAppStrings.actinides,
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background pattern
        Positioned.fill(
          child: CustomPaint(
            painter: MetalGroupPatternPainter(),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
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
                child: Icon(
                  Icons.build,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.metalGroups
                          : EnAppStrings.metalGroups,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required String title,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.science,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
}

import 'package:elements_app/core/mixin/animation_mixin.dart';
import 'package:elements_app/core/painter/home_pattern_painter.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/info_provider.dart';
import 'package:elements_app/feature/view/favorites/favorites_view.dart';
import 'package:elements_app/feature/view/groups/element_group_view.dart';
import 'package:elements_app/feature/view/info/modern_info_view.dart';
import 'package:elements_app/feature/view/periodicTable/periodic_table_view.dart';
import 'package:elements_app/feature/view/quiz/modern_quiz_home.dart';
import 'package:elements_app/feature/view/settings/settings_view.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';

import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

final class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<StatefulWidget>
    with TickerProviderStateMixin, AnimationMixin {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Navigator.pop(context);
          },
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Background Pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: HomePatternPainter(
                    color: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: fadeInWidget(
                          child: _buildHeader(context),
                        ),
                      ),
                    ),

                    // Hero Image Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: fadeSlideInWidget(
                          child: _buildHeroSection(context),
                        ),
                      ),
                    ),

                    // Main Features Grid
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverToBoxAdapter(
                        child: fadeSlideInWidget(
                          child: _buildFeaturesGrid(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isTr = context.select((LocalizationProvider p) => p.isTr);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue.withOpacity(0.7),
            AppColors.darkBlue.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row with Logo and Actions
          Row(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: SvgPicture.asset(
                  AssetConstants.instance.svgScienceTwo,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.9),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const Spacer(),
              // Action Buttons
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesView(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    icon: Icons.settings_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsView(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Title and Subtitle
          Text(
            isTr ? TrAppStrings.appName : EnAppStrings.appName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isTr ? 'Periyodik Tablo Keşfi' : 'Periodic Table Discovery',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

Widget _buildHeroSection(BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PeriodicTableView(),
        ),
      );
    },
    child: Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.2),
            AppColors.pink.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Image.asset(
              AssetConstants.instance.pngHomeImage,
              height: 150,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFeaturesGrid(BuildContext context) {
  return Column(
    children: [
      // First Row
      Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              context,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.allElements
                  : EnAppStrings.elements,
              subtitle: context.read<LocalizationProvider>().isTr
                  ? 'Tüm Elementler'
                  : 'All Elements',
              icon: AssetConstants.instance.svgScienceTwo,
              color: AppColors.turquoise,
              shadowColor: AppColors.shTurquoise,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ElementsListView(
                      apiType: ApiTypes.allElements,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.allElements
                          : EnAppStrings.elements,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildFeatureCard(
              context,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.groups
                  : EnAppStrings.groups,
              subtitle: context.read<LocalizationProvider>().isTr
                  ? 'Element Grupları'
                  : 'Element Groups',
              icon: AssetConstants.instance.svgElementGroup,
              color: AppColors.glowGreen,
              shadowColor: AppColors.shGlowGreen,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElementGroupView(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 15),
      // Second Row
      Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              context,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.what
                  : EnAppStrings.what,
              subtitle: context.read<LocalizationProvider>().isTr
                  ? 'Element Bilgileri'
                  : 'Element Info',
              icon: AssetConstants.instance.svgQuestionTwo,
              color: AppColors.yellow,
              shadowColor: AppColors.shYellow,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      final infoProvider = context.read<InfoProvider>();
                      infoProvider.fetchInfoList();
                      return const ModernInfoView();
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildFeatureCard(
              context,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.quiz
                  : EnAppStrings.quiz,
              subtitle: context.read<LocalizationProvider>().isTr
                  ? 'Bilgi Testi'
                  : 'Knowledge Quiz',
              icon: AssetConstants.instance.svgGameThree,
              color: AppColors.pink,
              shadowColor: AppColors.shPink,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModernQuizHome(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildFeatureCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required String icon,
  required Color color,
  required Color shadowColor,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(
                    icon,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

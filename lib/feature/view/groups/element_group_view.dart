import 'package:elements_app/core/painter/group_pattern_painter.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/feature/view/groups/metalGroup/metal_group_view.dart';
import 'package:elements_app/feature/view/groups/nonMetalGroup/non_metal_group_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/container/element_group_container.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Using GroupPatternPainter from /lib/core/painter/group_pattern_painter.dart

class ElementGroupView extends StatefulWidget {
  const ElementGroupView({super.key});

  @override
  State<ElementGroupView> createState() => _ElementGroupViewState();
}

class _ElementGroupViewState extends State<ElementGroupView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int? _pressedIndex;
  bool _unknownPressed = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  Color _getGroupColor() {
    // Return default color for element groups
    return AppColors.steelBlue;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildModernAppBar(context),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GroupPatternPainter(
                    AppColors.white.withValues(alpha: 0.03),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                            delegate: SliverChildListDelegate([
                              _buildGroupCard(
                                context,
                                index: 0,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.metalGroups
                                    : EnAppStrings.metalGroups,
                                leadingIcon: Icons.construction,
                                color: AppColors.purple,
                                shadowColor: AppColors.shPurple,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MetalGroupView(),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 1,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.nonMetalGroups
                                    : EnAppStrings.nonMetalGroup,
                                leadingIcon: Icons.bubble_chart,
                                color: AppColors.powderRed,
                                shadowColor: AppColors.shPowderRed,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NonMetalGroupView(),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 2,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.metalloidGroups
                                    : EnAppStrings.metalloidGroup,
                                leadingIcon: Icons.category,
                                color: AppColors.skinColor,
                                shadowColor: AppColors.shSkinColor,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.metalloid,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.metalloids
                                            : EnAppStrings.metalloids,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 3,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.halogenGroups
                                    : EnAppStrings.halogenGroup,
                                leadingIcon: Icons.flare,
                                color: AppColors.lightGreen,
                                shadowColor: AppColors.shLightGreen,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.halogen,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.halogenGroups
                                            : EnAppStrings.halogens,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ]),
                          ),
                        ),

                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverToBoxAdapter(
                            child: _buildUnknownGroupCard(
                              context,
                              title: context.read<LocalizationProvider>().isTr
                                  ? TrAppStrings.unknown
                                  : EnAppStrings.unknown,
                              color: AppColors.darkWhite,
                              shadowColor: AppColors.shDarkWhite,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.read<AdmobProvider>().onRouteChanged();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ElementsListView(
                                      apiType: ApiTypes.unknown,
                                      title:
                                          context
                                              .read<LocalizationProvider>()
                                              .isTr
                                          ? TrAppStrings.unknown
                                          : EnAppStrings.unknown,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Banner Ad
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: const BannerAdsWidget(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkBlue,
      leading: const ModernBackButton(),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.category, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              context.read<LocalizationProvider>().isTr
                  ? 'Element Grupları'
                  : 'Element Groups',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
      elevation: 0,
    );
  }

  ElementGroupContainer halogenContainer(BuildContext context) {
    return ElementGroupContainer(
      color: AppColors.lightGreen,
      shadowColor: AppColors.shLightGreen,
      onTap: () {
        context.read<AdmobProvider>().onRouteChanged();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElementsListView(
              apiType: ApiTypes.halogen,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.halogenGroups
                  : EnAppStrings.halogens,
            ),
          ),
        );
      },
      title: context.read<LocalizationProvider>().isTr
          ? TrAppStrings.halogenGroups
          : EnAppStrings.halogenGroup,
    );
  }

  Row metalloidAndUnknownRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [metalloidGroupContainer(context), halogenContainer(context)],
    );
  }

  Row metalAndNonmetalRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [metalGroupContainer(context), nonmetalGroupContainer(context)],
    );
  }

  ElementGroupContainer metalGroupContainer(BuildContext context) {
    return ElementGroupContainer(
      color: AppColors.purple,
      shadowColor: AppColors.shPurple,
      onTap: () {
        context.read<AdmobProvider>().onRouteChanged();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MetalGroupView()),
        );
      },
      title: context.read<LocalizationProvider>().isTr
          ? TrAppStrings.metalGroups
          : EnAppStrings.metalGroups,
    );
  }

  ElementGroupContainer nonmetalGroupContainer(BuildContext context) {
    return ElementGroupContainer(
      color: AppColors.powderRed,
      shadowColor: AppColors.shPowderRed,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NonMetalGroupView()),
        );
      },
      title: context.read<LocalizationProvider>().isTr
          ? TrAppStrings.nonMetalGroups
          : EnAppStrings.nonMetalGroup,
    );
  }

  ElementGroupContainer metalloidGroupContainer(BuildContext context) {
    return ElementGroupContainer(
      color: AppColors.skinColor,
      shadowColor: AppColors.shSkinColor,
      onTap: () {
        context.read<AdmobProvider>().onRouteChanged();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElementsListView(
              apiType: ApiTypes.metalloid,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.metalloids
                  : EnAppStrings.metalloids,
            ),
          ),
        );
      },
      title: context.read<LocalizationProvider>().isTr
          ? TrAppStrings.metalloidGroups
          : EnAppStrings.metalloidGroup,
    );
  }

  ElementGroupContainer unknownGroupContainer(BuildContext context) {
    return ElementGroupContainer(
      color: AppColors.darkWhite,
      shadowColor: AppColors.shDarkWhite,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElementsListView(
              apiType: ApiTypes.unknown,
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.unknown
                  : EnAppStrings.unknown,
            ),
          ),
        );
      },
      title: context.read<LocalizationProvider>().isTr
          ? TrAppStrings.unknown
          : EnAppStrings.unknown,
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required int index,
    required String title,
    required IconData leadingIcon,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTapDown: (_) => setState(() => _pressedIndex = index),
        onTapCancel: () => setState(() => _pressedIndex = null),
        onTap: () {
          setState(() => _pressedIndex = null);
          onTap();
        },
        onTapUp: (_) => setState(() => _pressedIndex = null),
        child: AnimatedScale(
          scale: _pressedIndex == index ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.1,
              ), // Opacity white background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.2,
                ), // Opacity white border
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GroupPatternPainter(
                        AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -15,
                    right: -15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Centered icon, title and subtitle
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _getGroupColor().withValues(
                                alpha: 0.6,
                              ), // Group color
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getGroupColor().withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getGroupColor().withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              leadingIcon,
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnknownGroupCard(
    BuildContext context, {
    required String title,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTapDown: (_) => setState(() => _unknownPressed = true),
        onTapCancel: () => setState(() => _unknownPressed = false),
        onTap: () {
          setState(() => _unknownPressed = false);
          onTap();
        },
        onTapUp: (_) => setState(() => _unknownPressed = false),
        child: AnimatedScale(
          scale: _unknownPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.1,
              ), // Opacity white background
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.2,
                ), // Opacity white border
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GroupPatternPainter(
                        AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -15,
                    right: -15,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.steelBlue.withValues(
                              alpha: 0.6,
                            ), // Help color
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.steelBlue.withValues(alpha: 0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.steelBlue.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: AppColors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.read<LocalizationProvider>().isTr
                                    ? 'Tanımlanmamış veya sınıflandırılmamış'
                                    : 'Unclassified or unspecified',
                                style: TextStyle(
                                  color: AppColors.white.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

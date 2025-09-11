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
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/container/element_group_container.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Using GroupPatternPainter from /lib/core/painter/group_pattern_painter.dart

class ElementGroupView extends StatelessWidget {
  const ElementGroupView({super.key});

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
                backgroundColor: AppColors.darkBlue,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.darkBlue,
                          AppColors.darkBlue.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: _buildHeader(context),
                  ),
                ),
                leading: ModernBackButton(),
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
                          ? TrAppStrings.metalGroups
                          : EnAppStrings.metalGroups,
                      color: AppColors.purple,
                      shadowColor: AppColors.shPurple,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MetalGroupView(),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.nonMetalGroups
                          : EnAppStrings.nonMetalGroup,
                      color: AppColors.powderRed,
                      shadowColor: AppColors.shPowderRed,
                      onTap: () {
                        context.read<AdmobProvider>().onRouteChanged();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NonMetalGroupView(),
                          ),
                        );
                      },
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.metalloidGroups
                          : EnAppStrings.metalloidGroup,
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
                    ),
                    _buildGroupCard(
                      context,
                      title: context.read<LocalizationProvider>().isTr
                          ? TrAppStrings.halogenGroups
                          : EnAppStrings.halogenGroup,
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
                    ),
                  ]),
                ),
              ),

              // Unknown Elements Section
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _buildUnknownGroupCard(
                    context,
                    title: context.read<LocalizationProvider>().isTr
                        ? TrAppStrings.unknown
                        : EnAppStrings.unknown,
                    color: AppColors.darkWhite,
                    shadowColor: AppColors.shDarkWhite,
                    onTap: () {
                      context.read<AdmobProvider>().onRouteChanged();
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      children: [
        metalloidGroupContainer(context),
        halogenContainer(
          context,
        ),
      ],
    );
  }

  Row metalAndNonmetalRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        metalGroupContainer(
          context,
        ),
        nonmetalGroupContainer(
          context,
        ),
      ],
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
          MaterialPageRoute(
            builder: (context) => const MetalGroupView(),
          ),
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
          MaterialPageRoute(
            builder: (context) => const NonMetalGroupView(),
          ),
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

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background pattern
        Positioned.fill(
          child: CustomPaint(
            painter: GroupPatternPainter(AppColors.white),
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
                  Icons.category,
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
                          ? 'Element Grupları'
                          : 'Element Groups',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.read<LocalizationProvider>().isTr
                          ? 'Elementleri gruplarına göre keşfedin'
                          : 'Explore elements by their groups',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 16,
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

  Widget _buildUnknownGroupCard(
    BuildContext context, {
    required String title,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 120,
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
            child: Row(
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
                    Icons.help_outline,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

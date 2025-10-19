import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MetalGroupView extends StatefulWidget {
  const MetalGroupView({super.key});

  @override
  State<MetalGroupView> createState() => _MetalGroupViewState();
}

class _MetalGroupViewState extends State<MetalGroupView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int? _pressedIndex;

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const BannerAdsWidget(showLoadingIndicator: true),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildGroupCard(
                                context,
                                index: 0,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.transitionMetal
                                    : EnAppStrings.transitionMetal,
                                leadingIcon: Icons.precision_manufacturing,
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
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.transitionMetal,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.transitionMetal
                                            : EnAppStrings.transitionMetal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 1,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.postTransition
                                    : EnAppStrings.postTransition,
                                leadingIcon: Icons.settings,
                                color: AppColors.steelBlue,
                                shadowColor: AppColors.shSteelBlue,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.postTransition,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.postTransition
                                            : EnAppStrings.postTransition,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 2,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.alkaline
                                    : EnAppStrings.alkaline,
                                leadingIcon: Icons.flash_on,
                                color: AppColors.turquoise,
                                shadowColor: AppColors.shTurquoise,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.alkaliMetal,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.alkaline
                                            : EnAppStrings.alkaline,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 3,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.earthAlkaline
                                    : EnAppStrings.earthAlkaline,
                                leadingIcon: Icons.construction,
                                color: AppColors.yellow,
                                shadowColor: AppColors.shYellow,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.alkalineEarthMetal,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.earthAlkaline
                                            : EnAppStrings.earthAlkaline,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 4,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.lanthanides
                                    : EnAppStrings.lanthanides,
                                leadingIcon: Icons.blur_circular,
                                color: AppColors.darkTurquoise,
                                shadowColor: AppColors.shDarkTurquoise,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.lanthanides,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.lanthanides
                                            : EnAppStrings.lanthanides,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildGroupCard(
                                context,
                                index: 5,
                                title: context.read<LocalizationProvider>().isTr
                                    ? TrAppStrings.actinides
                                    : EnAppStrings.actinides,
                                leadingIcon: Icons.science,
                                color: AppColors.pink,
                                shadowColor: AppColors.shPink,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context
                                      .read<AdmobProvider>()
                                      .onRouteChanged();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ElementsListView(
                                        apiType: ApiTypes.actinides,
                                        title:
                                            context
                                                .read<LocalizationProvider>()
                                                .isTr
                                            ? TrAppStrings.actinides
                                            : EnAppStrings.actinides,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
            child: const Icon(Icons.build, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            context.read<LocalizationProvider>().isTr
                ? TrAppStrings.metalGroups
                : EnAppStrings.metalGroups,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      elevation: 0,
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
    return GestureDetector(
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
            color: color.withValues(alpha: 0.15), // Element color background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.4), // Element color border
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3), // Element color shadow
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
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
                            color: color.withValues(alpha: 0.7), // Group color
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withValues(alpha: 0.9),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
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
                            fontSize: 18,
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
    );
  }
}

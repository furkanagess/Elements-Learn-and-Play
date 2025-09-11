import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetalGroupView extends StatelessWidget {
  const MetalGroupView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.purple,
      leading: const ModernBackButton(),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.build,
              color: AppColors.white,
              size: 20,
            ),
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

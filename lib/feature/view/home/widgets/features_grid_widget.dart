import 'package:elements_app/feature/provider/info_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/feature/view/groups/element_group_view.dart';
import 'package:elements_app/feature/view/home/widgets/feature_card_widget.dart';
import 'package:elements_app/feature/view/info/modern_info_view.dart';
import 'package:elements_app/feature/view/tests/tests_home_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeaturesGridWidget extends StatelessWidget {
  const FeaturesGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final isTr = localizationProvider.isTr;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title

            // Features Grid
            Column(
              children: [
                // First Row
                Row(
                  children: [
                    Expanded(
                      child: FeatureCardWidget(
                        title: isTr
                            ? TrAppStrings.allElements
                            : EnAppStrings.elements,
                        subtitle: isTr ? 'Tüm Elementler' : 'All Elements',
                        icon: AssetConstants.instance.svgScienceTwo,
                        color: AppColors.turquoise,
                        shadowColor: AppColors.shTurquoise,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ElementsListView(
                                apiType: ApiTypes.allElements,
                                title: isTr
                                    ? TrAppStrings.allElements
                                    : EnAppStrings.elements,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FeatureCardWidget(
                        title: isTr ? TrAppStrings.groups : EnAppStrings.groups,
                        subtitle: isTr ? 'Element Grupları' : 'Element Groups',
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
                const SizedBox(height: 16),
                // Second Row
                Row(
                  children: [
                    Expanded(
                      child: FeatureCardWidget(
                        title: isTr ? TrAppStrings.what : EnAppStrings.what,
                        subtitle: isTr ? 'Element Bilgileri' : 'Element Info',
                        icon: AssetConstants.instance.svgQuestionTwo,
                        color: AppColors.yellow,
                        shadowColor: AppColors.shYellow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                final infoProvider = context
                                    .read<InfoProvider>();
                                infoProvider.fetchInfoList();
                                return const ModernInfoView();
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FeatureCardWidget(
                        title: isTr ? 'Oyunlar' : 'Games',
                        subtitle: isTr
                            ? 'Quiz ve Bulmacalar'
                            : 'Quizzes and Puzzles',
                        icon: AssetConstants.instance.svgGameThree,
                        color: AppColors.pink,
                        shadowColor: AppColors.shPink,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestsHomeView(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Tests are centralized in TestsHomeView now
              ],
            ),
          ],
        );
      },
    );
  }
}

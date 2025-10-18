import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/feature/provider/info_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/product/widget/skeleton/universal_skeleton_loader.dart';
import 'package:elements_app/product/widget/card/modern_element_types_card.dart';
import 'package:elements_app/feature/view/info/subInfo/elementType/element_type_view.dart';
import 'package:elements_app/feature/view/info/subInfo/infoDetail/info_detail_view.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ModernInfoView extends StatefulWidget {
  const ModernInfoView({super.key});

  @override
  State<ModernInfoView> createState() => _ModernInfoViewState();
}

class _ModernInfoViewState extends State<ModernInfoView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Animation controllers for 3D button effects

  // Map to store scale controllers for each info card
  final Map<int, AnimationController> _scaleControllers = {};

  // Pattern service for background patterns
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Initialize element types scale animation

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();

    // Dispose all scale controllers
    for (var controller in _scaleControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // Animation methods for info cards

  @override
  Widget build(BuildContext context) {
    return Consumer<InfoProvider>(
      builder: (context, infoProvider, child) {
        // Show skeleton loading when loading
        if (infoProvider.isLoading) {
          return const UniversalSkeletonLoader(
            type: SkeletonType.infoCards,
            itemCount: 6,
          );
        }

        return AppScaffold(
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildModernAppBar(),
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
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildContent(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildModernAppBar() {
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
            child: SvgPicture.asset(
              AssetConstants.instance.svgQuestionTwo,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.read<LocalizationProvider>().isTr
                ? TrAppStrings.what
                : EnAppStrings.what,
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

  Widget _buildContent() {
    return Consumer<InfoProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchInfoList(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.infoList.isEmpty) {
          return const Center(
            child: Text(
              'No information available',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          itemCount:
              provider.infoList.length + 2, // +1 banner, +1 element types card
          itemBuilder: (context, index) {
            // First item is banner ads
            if (index == 0) {
              return const BannerAdsWidget(showLoadingIndicator: true);
            }

            // Second item is element types card
            if (index == 1) {
              return AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: ModernElementTypesCard(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ElementTypeView(
                                apiType: ApiTypes.elementTypes,
                                title: 'Element Types',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }

            // Other items are info cards
            final info = provider.infoList[index - 2];
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                    child: ModernInfoCard(
                      title: context.read<LocalizationProvider>().isTr
                          ? info.trTitle ?? ''
                          : info.enTitle ?? '',
                      subtitle: context.read<LocalizationProvider>().isTr
                          ? info.trDesc1 ?? ''
                          : info.enDesc1 ?? '',
                      iconPath:
                          info.svg ?? AssetConstants.instance.svgQuestionTwo,
                      iconColor: info.colors?.toColor(),
                      onTap: () => _onInfoCardTap(info),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _onInfoCardTap(Info info) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoDetailView(info: info)),
    );
  }
}

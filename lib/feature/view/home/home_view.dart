import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/groups/element_group_view.dart';
import 'package:elements_app/feature/view/info/info_view.dart';
import 'package:elements_app/feature/view/quiz/quiz_home.dart';
import 'package:elements_app/feature/view/search/search_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:elements_app/product/widget/button/gradient_button.dart';

import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/text/text_icon_row.dart';
import 'package:elements_app/product/widget/textField/long_feedback_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:provider/provider.dart';

final class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends State<StatefulWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(context),
                  ),
                  const SizedBox(height: 30),

                  // Hero Image Section
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildHeroSection(context),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Main Features Grid
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildFeaturesGrid(context),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bottom Actions
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildBottomActions(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Banner Ads
                  const BannerAdsWidget(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withOpacity(0.1),
            AppColors.purple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.purple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: SvgPicture.asset(
              AssetConstants.instance.svgScienceTwo,
              height: 30,
              colorFilter: const ColorFilter.mode(
                AppColors.purple,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeonText(
                  text: context.read<LocalizationProvider>().isTr
                      ? TrAppStrings.appName
                      : EnAppStrings.appName,
                  fontWeight: FontWeight.bold,
                  isSoftWrap: true,
                  spreadColor: AppColors.purple,
                  blurRadius: 15,
                ),
                const SizedBox(height: 4),
                Text(
                  context.read<LocalizationProvider>().isTr
                      ? 'Periyodik Tablo Keşfi'
                      : 'Periodic Table Discovery',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withOpacity(0.2),
            AppColors.pink.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.1),
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
                color: AppColors.purple.withOpacity(0.1),
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
                  context.read<AdmobProvider>().onRouteChanged();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchView(),
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
                  context.read<AdmobProvider>().onRouteChanged();
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
                  context.read<AdmobProvider>().onRouteChanged();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoView(
                        apiType: ApiTypes.whatIs,
                        title: context.read<LocalizationProvider>().isTr
                            ? TrAppStrings.what
                            : EnAppStrings.what,
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
                    ? TrAppStrings.quiz
                    : EnAppStrings.quiz,
                subtitle: context.read<LocalizationProvider>().isTr
                    ? 'Bilgi Testi'
                    : 'Knowledge Quiz',
                icon: AssetConstants.instance.svgGameThree,
                color: AppColors.pink,
                shadowColor: AppColors.shPink,
                onTap: () {
                  context.read<AdmobProvider>().onRouteChanged();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizHomeView(),
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
              color.withOpacity(0.9),
              color.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.3),
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
                      color: Colors.white.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.7),
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
                  color: Colors.white.withOpacity(0.8),
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

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            icon: AssetConstants.instance.svgTrFlag,
            label: context.read<LocalizationProvider>().isTr ? 'EN' : 'TR',
            onTap: () {
              Provider.of<LocalizationProvider>(context, listen: false)
                  .toggleBool();
            },
          ),
          _buildActionButton(
            context,
            icon: AssetConstants.instance.svgStarTwo,
            label: context.read<LocalizationProvider>().isTr
                ? TrAppStrings.rateTitle
                : EnAppStrings.rateTitle,
            onTap: () => rateBottomSheet(context),
          ),
          _buildActionButton(
            context,
            icon: AssetConstants.instance.svgQuestion,
            label:
                context.read<LocalizationProvider>().isTr ? 'Yardım' : 'Help',
            onTap: () => helpPopUp(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: SvgPicture.asset(
              icon,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.purple,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  SizedBox spacerVertical(BuildContext context, double value) =>
      SizedBox(height: context.dynamicHeight(value));

  SizedBox spacerHorizontal(BuildContext context, double value) =>
      SizedBox(height: context.dynamicWidth(value));

  // Existing methods for bottom sheets and dialogs
  Future<dynamic> rateBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      isDismissible: false,
      builder: (context) => Padding(
        padding: context.paddingLowVertical,
        child: Container(
          width: context.width,
          height: context.dynamicHeight(0.5),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                  ),
                ),
              ),
              Image.asset(
                AssetConstants.instance.pngStarLogo,
                width: context.width,
                height: context.dynamicHeight(0.2),
              ),
              Padding(
                padding: context.paddingNormal,
                child: Text(
                  context.read<LocalizationProvider>().isTr
                      ? TrAppStrings.rateDescription
                      : EnAppStrings.rateDescription,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: AppColors.white,
                  ),
                  maxLines: 4,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: context.dynamicHeight(0.03),
              ),
              GradientButton(
                onTap: () async {
                  Navigator.pop(context);
                  final InAppReview inAppReview = InAppReview.instance;
                  if (await inAppReview.isAvailable()) {
                    await inAppReview.openStoreListing();
                  }
                },
                title: context.read<LocalizationProvider>().isTr
                    ? TrAppStrings.rateTitle
                    : EnAppStrings.rateTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> helpPopUp(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        elevation: 3,
        backgroundColor: AppColors.background,
        title: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.white,
                  )),
            ),
            Image.asset(
              AssetConstants.instance.pnginfoLogo,
              width: context.width,
              height: context.dynamicHeight(0.1),
            ),
            spacerVertical(context, 0.01),
            TextIconRow(
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.help1
                  : EnAppStrings.help1,
              color: AppColors.purple,
            ),
            spacerVertical(context, 0.01),
            TextIconRow(
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.help2
                  : EnAppStrings.help2,
              color: AppColors.yellow,
            ),
            spacerVertical(context, 0.01),
            TextIconRow(
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.help3
                  : EnAppStrings.help3,
              color: AppColors.glowGreen,
            ),
            spacerVertical(context, 0.01),
            TextIconRow(
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.help4
                  : EnAppStrings.help4,
              color: AppColors.powderRed,
            ),
            spacerVertical(context, 0.01),
            TextIconRow(
              title: context.read<LocalizationProvider>().isTr
                  ? TrAppStrings.help5
                  : EnAppStrings.help5,
              color: AppColors.turquoise,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> reportBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: AppColors.powderRed,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Column(
            children: [
              spacerVertical(context, 0.05),
              const FeedbackLongTextField(
                title: EnAppStrings.feedback,
              ),
              spacerVertical(context, 0.01),
              GradientButton(
                title: EnAppStrings.sendFeedback,
                onTap: () => Navigator.pop(context),
              ),
              spacerVertical(context, 0.01),
            ],
          ),
        ),
      ),
    );
  }

  Text headerGroupText(BuildContext context) {
    return Text(
      EnAppStrings.appName,
      style: context.textTheme.labelLarge?.copyWith(
        color: AppColors.white,
      ),
    );
  }

  Text headerElementText(BuildContext context) {
    return Text(
      context.read<LocalizationProvider>().isTr
          ? TrAppStrings.allElements
          : EnAppStrings.allElements,
      style: context.textTheme.labelLarge?.copyWith(
        color: AppColors.white,
      ),
    );
  }
}

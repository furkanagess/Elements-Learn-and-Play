import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:flutter/material.dart';
import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/feature/provider/info_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/view/elementsList/elements_loading_view.dart';
import 'package:elements_app/feature/view/info/subInfo/elementType/element_type_view.dart';
import 'package:elements_app/feature/view/info/subInfo/infoDetail/info_detail_view.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
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
  late AnimationController _elementTypesScaleController;
  late Animation<double> _elementTypesScaleAnimation;

  // Map to store scale controllers for each info card
  final Map<int, AnimationController> _scaleControllers = {};
  final Map<int, Animation<double>> _scaleAnimations = {};

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
    _elementTypesScaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _elementTypesScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _elementTypesScaleController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _elementTypesScaleController.dispose();

    // Dispose all scale controllers
    for (var controller in _scaleControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // Animation methods for element types card
  void _onElementTypesTapDown(TapDownDetails details) {
    _elementTypesScaleController.forward();
  }

  void _onElementTypesTapUp(TapUpDetails details) {
    _elementTypesScaleController.reverse();
    HapticFeedback.lightImpact();
    _navigateToElementTypes();
  }

  void _onElementTypesTapCancel() {
    _elementTypesScaleController.reverse();
  }

  void _navigateToElementTypes() {
    context.read<AdmobProvider>().onRouteChanged();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ElementTypeView(
          apiType: ApiTypes.elementTypes,
          title: context.read<LocalizationProvider>().isTr
              ? TrAppStrings.elementTypes
              : EnAppStrings.elementTypes,
        ),
      ),
    );
  }

  // Animation methods for info cards
  void _onInfoCardTapDown(TapDownDetails details, int index) {
    _getOrCreateScaleController(index).forward();
  }

  void _onInfoCardTapUp(TapUpDetails details, int index, Info info) {
    _getOrCreateScaleController(index).reverse();
    HapticFeedback.lightImpact();
    _navigateToInfoDetail(info);
  }

  void _onInfoCardTapCancel(int index) {
    _getOrCreateScaleController(index).reverse();
  }

  void _navigateToInfoDetail(Info info) {
    context.read<AdmobProvider>().onRouteChanged();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoDetailView(info: info)),
    );
  }

  // Helper method to get or create scale controller for each card
  AnimationController _getOrCreateScaleController(int index) {
    if (!_scaleControllers.containsKey(index)) {
      _scaleControllers[index] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      _scaleAnimations[index] = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: _scaleControllers[index]!,
          curve: Curves.easeInOut,
        ),
      );
    }
    return _scaleControllers[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InfoProvider>(
      builder: (context, infoProvider, child) {
        // Show loading screen when loading
        if (infoProvider.isLoading) {
          return const ElementsLoadingView();
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
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBlue,
              AppColors.purple.withValues(alpha: 0.95),
              AppColors.turquoise.withValues(alpha: 0.9),
            ],
          ),
        ),
      ),
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

  Widget _buildElementTypesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: _onElementTypesTapDown,
          onTapUp: _onElementTypesTapUp,
          onTapCancel: _onElementTypesTapCancel,
          child: AnimatedBuilder(
            animation: _elementTypesScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _elementTypesScaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.purple.withValues(alpha: 0.9),
                        AppColors.pink.withValues(alpha: 0.7),
                        AppColors.turquoise.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: AppColors.pink.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _patternService.getPatternPainter(
                              type: PatternType.molecular,
                              color: Colors.white,
                              opacity: 0.1,
                            ),
                          ),
                        ),

                        // Decorative Elements
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
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  AssetConstants.instance.svgQuestionTwo,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.read<LocalizationProvider>().isTr
                                          ? TrAppStrings.elementTypes
                                          : EnAppStrings.elementTypes,
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.read<LocalizationProvider>().isTr
                                          ? 'Element türlerini keşfet'
                                          : 'Explore element types',
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.8,
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

                              // Arrow Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
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
              );
            },
          ),
        ),
      ),
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
          itemCount: provider.infoList.length + 1, // +1 for element types card
          itemBuilder: (context, index) {
            // First item is element types card
            if (index == 0) {
              return AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: _buildElementTypesCard(),
                    ),
                  );
                },
              );
            }

            // Other items are info cards
            final info = provider.infoList[index - 1];
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                    child: _buildModernInfoCard(info, index - 1),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildModernInfoCard(Info info, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: (details) => _onInfoCardTapDown(details, index),
          onTapUp: (details) => _onInfoCardTapUp(details, index, info),
          onTapCancel: () => _onInfoCardTapCancel(index),
          child: AnimatedBuilder(
            animation: _getOrCreateScaleController(index),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[index]?.value ?? 1.0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        (info.colors?.toColor() ?? AppColors.darkBlue)
                            .withValues(alpha: 0.9),
                        (info.colors?.toColor() ?? AppColors.darkBlue)
                            .withValues(alpha: 0.7),
                        (info.colors?.toColor() ?? AppColors.darkBlue)
                            .withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (info.colors?.toColor() ?? AppColors.darkBlue)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: (info.colors?.toColor() ?? AppColors.darkBlue)
                            .withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _patternService.getRandomPatternPainter(
                              seed: index,
                              color: Colors.white,
                              opacity: 0.1,
                            ),
                          ),
                        ),

                        // Decorative Elements
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
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Main Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  AssetConstants.instance.svgQuestionTwo,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Text Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      context.read<LocalizationProvider>().isTr
                                          ? info.trTitle ?? ''
                                          : info.enTitle ?? '',
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.read<LocalizationProvider>().isTr
                                          ? info.trDesc1 ?? ''
                                          : info.enDesc1 ?? '',
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.8,
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

                              // Arrow Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

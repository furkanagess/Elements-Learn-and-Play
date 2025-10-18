import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/core/services/data/data_service.dart';
import 'package:elements_app/product/widget/skeleton/universal_skeleton_loader.dart';
import 'package:elements_app/product/widget/card/modern_element_types_card.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/feature/view/info/subInfo/infoDetail/info_detail_view.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ElementTypeView extends StatefulWidget {
  final String apiType;
  final String title;
  const ElementTypeView({
    super.key,
    required this.apiType,
    required this.title,
  });

  @override
  State<ElementTypeView> createState() => _ElementTypeViewState();
}

class _ElementTypeViewState extends State<ElementTypeView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Data service and state
  final DataService _dataService = DataService();
  late Future<List<Info>> _infoList;
  bool _isLoading = true;

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

    _fadeController.forward();

    // Initialize data fetching
    _initializeData();
  }

  void _initializeData() {
    _infoList = _dataService.fetchInfo(widget.apiType);

    // Load data immediately without artificial delay
    _infoList
        .then((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton loading when loading
    if (_isLoading) {
      return const UniversalSkeletonLoader(
        type: SkeletonType.infoCards,
        itemCount: 4,
      );
    }

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildModernAppBar(),
        body: Stack(
          children: [
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
              AssetConstants.instance.svgElementGroup,
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
            widget.title,
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

  Color _getElementTypeColor(int index) {
    final colors = [
      AppColors.yellow, // Alkaline Metals
      AppColors.pink, // Actinides
      AppColors.purple, // Transition Metals
      AppColors.turquoise, // Alkaline Earth Metals
      AppColors.lightGreen, // Halogens
      AppColors.darkTurquoise, // Lanthanides
      AppColors.darkWhite, // Unknown
      AppColors.skinColor, // Metalloids
      AppColors.glowGreen, // Noble Gases
      AppColors.powderRed, // Reactive Nonmetals
      AppColors.steelBlue, // Post Transition Metals
    ];
    return colors[index % colors.length];
  }

  Widget _buildContent() {
    return FutureBuilder<List<Info>>(
      future: _infoList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const UniversalSkeletonLoader(
            type: SkeletonType.infoCards,
            itemCount: 4,
            showAppBar: false,
          );
        } else {
          final infos = snapshot.data;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            itemCount: (infos?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const BannerAdsWidget(showLoadingIndicator: true);
              }

              final info = infos![index - 1];
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
                            info.svg ?? AssetConstants.instance.svgElementGroup,
                        iconColor: _getElementTypeColor(index - 1),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.read<AdmobProvider>().onRouteChanged();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfoDetailView(info: info),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

import 'package:elements_app/core/painter/periodic_table_painters.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/skeleton/universal_skeleton_loader.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PeriodicTableView extends StatefulWidget {
  const PeriodicTableView({super.key});

  @override
  State<PeriodicTableView> createState() => _PeriodicTableViewState();
}

class _PeriodicTableViewState extends State<PeriodicTableView> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodicTableProvider>().loadElements();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
        appBar: _buildAppBar(context),
        body: _buildContent(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;

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
            child: const Icon(
              Icons.grid_view_outlined,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? TrAppStrings.periodicTable : EnAppStrings.periodicTable,
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

  Widget _buildContent(BuildContext context) {
    return Consumer<PeriodicTableProvider>(
      builder: (context, provider, child) {
        if (provider.state.isLoading) {
          return const UniversalSkeletonLoader(
            type: SkeletonType.periodicTable,
            showAppBar: false,
          );
        }

        if (provider.state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.white.withValues(alpha: 0.6),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.state.error!,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: true),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: 1080,
                          height: 660,
                          child: InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: 0.5,
                            maxScale: 3.0,
                            onInteractionUpdate: (details) {
                              provider.updateScale(
                                _transformationController.value
                                    .getMaxScaleOnAxis(),
                              );
                            },
                            child: Stack(
                              children: [
                                // Background grid
                                _buildGrid(),

                                // Elements
                                ...provider.filteredElements.map((element) {
                                  final position = provider.getElementPosition(
                                    element,
                                  );
                                  return Positioned(
                                    left: position.dx,
                                    top: position.dy,
                                    child: _buildElementTile(context, element),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: BannerAdsWidget(showLoadingIndicator: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      painter: GridPatternPainter(),
      size: const Size(1080, 660), // 18x11 grid, her hücre 60x60
    );
  }

  Widget _buildElementTile(BuildContext context, element) {
    final provider = context.watch<PeriodicTableProvider>();
    final color = provider.getElementColor(element);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElementDetailView(element: element),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element.number?.toString() ?? '',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              element.symbol ?? '',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.read<LocalizationProvider>().isTr
                  ? element.trName ?? ''
                  : element.enName ?? '',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

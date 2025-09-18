import 'package:elements_app/core/painter/periodic_table_painters.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/feature/view/elementsList/elements_loading_view.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';
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
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: _buildContent(context),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;

    return AppBarConfigs.periodicTable(
      title: isTr ? TrAppStrings.periodicTable : EnAppStrings.periodicTable,
    ).toAppBar();
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<PeriodicTableProvider>(
      builder: (context, provider, child) {
        if (provider.state.isLoading) {
          return const ElementsLoadingView();
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

                                // Visualizations
                                if (provider.state.showElectronicConfig)
                                  _buildElectronicConfig(provider),
                                if (provider.state.showAtomicModel)
                                  _buildAtomicModel(provider),
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
    final isSelected = element == provider.state.selectedElement;
    final color = provider.getElementColor(element);

    return GestureDetector(
      onTap: () {
        provider.selectElement(element);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElementDetailView(element: element),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
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

  Widget _buildElectronicConfig(PeriodicTableProvider provider) {
    if (provider.state.selectedElement == null) return const SizedBox.shrink();

    return CustomPaint(
      painter: ElectronicConfigPainter(
        element: provider.state.selectedElement!,
      ),
      size: const Size(1200, 800),
    );
  }

  Widget _buildAtomicModel(PeriodicTableProvider provider) {
    if (provider.state.selectedElement == null) return const SizedBox.shrink();

    return CustomPaint(
      painter: AtomicModelPainter(element: provider.state.selectedElement!),
      size: const Size(1200, 800),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Consumer2<PeriodicTableProvider, LocalizationProvider>(
      builder: (context, provider, localizationProvider, child) {
        if (provider.state.selectedElement == null) {
          return const SizedBox.shrink();
        }

        final isTr = localizationProvider.isTr;

        return FloatingActionButton.extended(
          onPressed: () => provider.selectElement(null),
          backgroundColor: AppColors.glowGreen,
          icon: const Icon(Icons.clear, color: AppColors.white),
          label: Text(
            isTr ? 'Seçimi Temizle' : 'Clear Selection',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

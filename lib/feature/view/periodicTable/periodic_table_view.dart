import 'package:elements_app/core/painter/periodic_table_painters.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/feature/view/elementsList/elements_loading_view.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  AppBar _buildAppBar(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;

    return AppBar(
      backgroundColor: AppColors.purple,
      leading: const ModernBackButton(),
      title: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              AssetConstants.instance.svgElementGroup,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Text(
            isTr ? TrAppStrings.periodicTable : EnAppStrings.periodicTable,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: _buildActionButtons(context),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final provider = context.watch<PeriodicTableProvider>();

    return [
      // Atomic Model Toggle
      Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: provider.state.showAtomicModel
              ? AppColors.glowGreen.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.science,
            color: provider.state.showAtomicModel
                ? AppColors.glowGreen
                : AppColors.white,
          ),
          onPressed: () => provider.toggleAtomicModel(),
          tooltip: 'Atomic Model',
        ),
      ),

      // Electronic Config Toggle
      Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: provider.state.showElectronicConfig
              ? AppColors.glowGreen.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(
            Icons.architecture,
            color: provider.state.showElectronicConfig
                ? AppColors.glowGreen
                : AppColors.white,
          ),
          onPressed: () => provider.toggleElectronicConfig(),
          tooltip: 'Electronic Configuration',
        ),
      ),
    ];
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

        return Container(
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
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: true),
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
                        provider.updateScale(_transformationController.value
                            .getMaxScaleOnAxis());
                      },
                      child: Stack(
                        children: [
                          // Background grid
                          _buildGrid(),

                          // Elements
                          ...provider.filteredElements.map((element) {
                            final position =
                                provider.getElementPosition(element);
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
      painter: AtomicModelPainter(
        element: provider.state.selectedElement!,
      ),
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

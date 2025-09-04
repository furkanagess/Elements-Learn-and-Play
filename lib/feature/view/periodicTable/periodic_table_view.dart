import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:elements_app/feature/view/elementDetail/element_detail_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/loadingBar/loading_bar.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
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
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildContent(context),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          Text(
            context.read<LocalizationProvider>().isTr
                ? 'Periyodik Tablo'
                : 'Periodic Table',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildControlButtons(context),
        ],
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    final provider = context.watch<PeriodicTableProvider>();
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.science,
            color: provider.state.showAtomicModel
                ? AppColors.glowGreen
                : AppColors.white,
          ),
          onPressed: () => provider.toggleAtomicModel(),
        ),
        IconButton(
          icon: Icon(
            Icons.architecture,
            color: provider.state.showElectronicConfig
                ? AppColors.glowGreen
                : AppColors.white,
          ),
          onPressed: () => provider.toggleElectronicConfig(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Consumer<PeriodicTableProvider>(
      builder: (context, provider, child) {
        if (provider.state.isLoading) {
          return const ComprehensiveLoadingBar(
            loadingText: 'Periyodik tablo yükleniyor...',
          );
        }

        if (provider.state.error != null) {
          return Center(
            child: Text(
              provider.state.error!,
              style: const TextStyle(color: AppColors.white),
            ),
          );
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: true),
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
                        _transformationController.value.getMaxScaleOnAxis());
                  },
                  child: Stack(
                    children: [
                      // Background grid
                      _buildGrid(),

                      // Elements
                      ...provider.filteredElements.map((element) {
                        final position = provider.getElementPosition(element);
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
        );
      },
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      painter: GridPainter(),
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
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? AppColors.white : AppColors.white.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              element.number?.toString() ?? '',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 10,
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
                color: AppColors.white.withOpacity(0.7),
                fontSize: 8,
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
    return Consumer<PeriodicTableProvider>(
      builder: (context, provider, child) {
        if (provider.state.selectedElement == null)
          return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => provider.selectElement(null),
          backgroundColor: AppColors.glowGreen,
          label: Text(
            context.read<LocalizationProvider>().isTr
                ? 'Seçimi Temizle'
                : 'Clear Selection',
            style: const TextStyle(color: AppColors.white),
          ),
          icon: const Icon(Icons.clear, color: AppColors.white),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    // Vertical lines
    for (var i = 0; i <= size.width; i += 60) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    // Horizontal lines
    for (var i = 0; i <= size.height; i += 60) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }

    // Lantanit ve Aktinit bölgeleri için özel çizgiler
    final specialPaint = Paint()
      ..color = AppColors.white.withOpacity(0.1)
      ..strokeWidth = 2;

    // Lantanit bölgesi (8. satır)
    canvas.drawRect(
      Rect.fromLTWH(180, 480, 840, 60),
      specialPaint,
    );

    // Aktinit bölgesi (9. satır)
    canvas.drawRect(
      Rect.fromLTWH(180, 540, 840, 60),
      specialPaint,
    );

    // Bağlantı çizgileri
    final arrowPaint = Paint()
      ..color = AppColors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Lantanit bağlantısı (La -> Ce)
    canvas.drawPath(
      Path()
        ..moveTo(120, 300) // La
        ..lineTo(140, 300)
        ..lineTo(140, 480)
        ..lineTo(180, 480), // Ce
      arrowPaint,
    );

    // Aktinit bağlantısı (Ac -> Th)
    canvas.drawPath(
      Path()
        ..moveTo(120, 360) // Ac
        ..lineTo(160, 360)
        ..lineTo(160, 540)
        ..lineTo(180, 540), // Th
      arrowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ElectronicConfigPainter extends CustomPainter {
  final PeriodicElement element;

  ElectronicConfigPainter({required this.element});

  @override
  void paint(Canvas canvas, Size size) {
    // Elektronik konfigürasyon görselleştirmesi
    // TODO: Implement electronic configuration visualization
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AtomicModelPainter extends CustomPainter {
  final PeriodicElement element;

  AtomicModelPainter({required this.element});

  @override
  void paint(Canvas canvas, Size size) {
    // Atom modeli görselleştirmesi
    // TODO: Implement atomic model visualization
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

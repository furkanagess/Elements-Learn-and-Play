// ignore_for_file: deprecated_member_use

import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class InfoDetailView extends StatefulWidget {
  final Info info;

  const InfoDetailView({super.key, required this.info});

  @override
  State<InfoDetailView> createState() => _InfoDetailViewState();
}

class _InfoDetailViewState extends State<InfoDetailView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late List<AnimationController> _flashcardControllers;
  late List<Animation<double>> _flashcardAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();

    // Initialize flashcard animations
    _flashcardControllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _flashcardAnimations = _flashcardControllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // Start flashcard animations with delay
    _startFlashcardAnimations();
  }

  void _startFlashcardAnimations() {
    for (int i = 0; i < _flashcardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 150)), () {
        if (mounted) {
          _flashcardControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (var controller in _flashcardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

      elevation: 0,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Icon with modern compact design
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.purple.withValues(alpha: 0.15),
                    AppColors.pink.withValues(alpha: 0.1),
                    AppColors.turquoise.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                widget.info.svg!,
                colorFilter: const ColorFilter.mode(
                  AppColors.white,
                  BlendMode.srcIn,
                ),
                width: 48,
                height: 48,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title with modern styling
          Text(
            context.read<LocalizationProvider>().isTr
                ? widget.info.trTitle ?? ''
                : widget.info.enTitle ?? '',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Element Properties Card (if data is available)
          if (widget.info.electronegativity != null ||
              widget.info.atomicRadius != null ||
              widget.info.electronConfiguration != null)
            _buildElementPropertiesCard(),

          if (widget.info.electronegativity != null ||
              widget.info.atomicRadius != null ||
              widget.info.electronConfiguration != null)
            const SizedBox(height: 24),

          // Flashcard Collection
          Column(
            children: [
              _buildFlashcard(
                context.read<LocalizationProvider>().isTr
                    ? widget.info.trDesc1 ?? ''
                    : widget.info.enDesc1 ?? '',
                'Info 1',
                AppColors.purple,
                0,
              ),
              const SizedBox(height: 16),
              _buildFlashcard(
                context.read<LocalizationProvider>().isTr
                    ? widget.info.trDesc2 ?? ''
                    : widget.info.enDesc2 ?? '',
                'Info 2',
                AppColors.pink,
                1,
              ),
              const SizedBox(height: 16),
              _buildFlashcard(
                context.read<LocalizationProvider>().isTr
                    ? widget.info.trDesc3 ?? ''
                    : widget.info.enDesc3 ?? '',
                'Info 3',
                AppColors.turquoise,
                2,
              ),
              const SizedBox(height: 16),
              _buildFlashcard(
                context.read<LocalizationProvider>().isTr
                    ? widget.info.trDesc4 ?? ''
                    : widget.info.enDesc4 ?? '',
                'Info 4',
                AppColors.steelBlue,
                3,
              ),
              const SizedBox(height: 16),
              _buildFlashcard(
                context.read<LocalizationProvider>().isTr
                    ? widget.info.trDesc5 ?? ''
                    : widget.info.enDesc5 ?? '',
                'Info 5',
                AppColors.glowGreen,
                4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Removed _dividerSVG as we now use flashcard format

  Widget _buildFlashcard(
    String content,
    String title,
    Color cardColor,
    int index,
  ) {
    if (content.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _flashcardAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _flashcardAnimations[index].value)),
          child: Opacity(
            opacity: _flashcardAnimations[index].value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardColor.withValues(alpha: 0.2),
                    cardColor.withValues(alpha: 0.15),
                    cardColor.withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: cardColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Decorative corner elements
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              cardColor.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(40),
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with icon and title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  widget.info.svg!,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    color: cardColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Content text
                          Text(
                            content,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Removed _usageParagraph as we now use flashcard format

  Widget _buildElementPropertiesCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.steelBlue.withValues(alpha: 0.15),
            AppColors.purple.withValues(alpha: 0.12),
            AppColors.pink.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.steelBlue.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Element Özellikleri',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Properties
            if (widget.info.electronegativity != null)
              _buildPropertyRow(
                'Elektronegatiflik',
                widget.info.electronegativity!.toString(),
                '',
                Icons.electric_bolt,
              ),
            if (widget.info.atomicRadius != null)
              _buildPropertyRow(
                'Atom Yarıçapı',
                widget.info.atomicRadius!.toString(),
                'pm',
                Icons.radio_button_unchecked,
              ),
            if (widget.info.electronConfiguration != null)
              _buildPropertyRow(
                'Elektron Konfigürasyonu',
                widget.info.electronConfiguration!,
                '',
                Icons.science_outlined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.8),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              unit.isNotEmpty ? '$value $unit' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

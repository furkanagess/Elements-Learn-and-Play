import 'package:elements_app/core/painter/group_pattern_painter.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/elementsList/elements_list_view.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NonMetalGroupView extends StatefulWidget {
  const NonMetalGroupView({super.key});

  @override
  State<NonMetalGroupView> createState() => _NonMetalGroupViewState();
}

class _NonMetalGroupViewState extends State<NonMetalGroupView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int? _pressedIndex;

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: GroupPatternPainter(
                  AppColors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                      children: [
                        _buildGroupCard(
                          context,
                          index: 0,
                          title: context.read<LocalizationProvider>().isTr
                              ? TrAppStrings.reactiveNonmetal
                              : EnAppStrings.reactiveNonmetal,
                          subtitle: context.read<LocalizationProvider>().isTr
                              ? 'reaktif ametaller'
                              : 'reactive nonmetals',
                          leadingIcon: Icons.bubble_chart,
                          color: AppColors.powderRed,
                          shadowColor: AppColors.shPowderRed,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<AdmobProvider>().onRouteChanged();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ElementsListView(
                                  apiType: ApiTypes.reactiveNonmetal,
                                  title:
                                      context.read<LocalizationProvider>().isTr
                                      ? TrAppStrings.reactiveNonmetal
                                      : EnAppStrings.reactiveNonmetal,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildGroupCard(
                          context,
                          index: 1,
                          title: context.read<LocalizationProvider>().isTr
                              ? TrAppStrings.nobleGases
                              : EnAppStrings.nobleGases,
                          subtitle: context.read<LocalizationProvider>().isTr
                              ? 'soy gazlar'
                              : 'noble gases',
                          leadingIcon: Icons.blur_on,
                          color: AppColors.glowGreen,
                          shadowColor: AppColors.shGlowGreen,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.read<AdmobProvider>().onRouteChanged();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ElementsListView(
                                  apiType: ApiTypes.nobleGases,
                                  title:
                                      context.read<LocalizationProvider>().isTr
                                      ? TrAppStrings.nobleGases
                                      : EnAppStrings.nobleGases,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.powderRed,
              AppColors.glowGreen.withValues(alpha: 0.95),
              AppColors.darkBlue.withValues(alpha: 0.9),
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
            child: const Icon(
              Icons.water_drop,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.read<LocalizationProvider>().isTr
                ? TrAppStrings.nonMetalGroups
                : EnAppStrings.nonMetalGroup,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context, {
    required int index,
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required Color color,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTapDown: (_) => setState(() => _pressedIndex = index),
        onTapCancel: () => setState(() => _pressedIndex = null),
        onTap: () {
          setState(() => _pressedIndex = null);
          onTap();
        },
        onTapUp: (_) => setState(() => _pressedIndex = null),
        child: AnimatedScale(
          scale: _pressedIndex == index ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.85)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: GroupPatternPainter(
                        AppColors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
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
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              leadingIcon,
                              color: AppColors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

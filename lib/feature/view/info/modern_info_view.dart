import 'package:flutter/material.dart';
import 'package:elements_app/core/painter/info_pattern_painter.dart';
import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/feature/provider/info_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/extensions/context_extensions.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/view/info/modern_info_detail_view.dart';
import 'package:elements_app/product/widget/info/info_card.dart';

class ModernInfoView extends StatefulWidget {
  const ModernInfoView({super.key});

  @override
  State<ModernInfoView> createState() => _ModernInfoViewState();
}

class _ModernInfoViewState extends State<ModernInfoView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.darkBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBlue,
                AppColors.darkBlue.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildPattern(),
              _buildHeader(context),
            ],
          ),
        ),
      ),
      leading: BackButton(),
    );
  }

  Widget _buildPattern() {
    return CustomPaint(
      painter: InfoPatternPainter(
        color: Colors.white.withOpacity(0.05),
      ),
      child: Container(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isTr = context.select((LocalizationProvider p) => p.isTr);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SvgPicture.asset(
              AssetConstants.instance.svgQuestionTwo,
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTr ? 'Nedir?' : 'What is?',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isTr
                      ? 'Periyodik tablo hakkında merak ettikleriniz'
                      : 'Learn about the periodic table',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      sliver: Consumer<InfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.white,
                ),
              ),
            );
          }

          if (provider.error != null) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
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
              ),
            );
          }

          if (provider.infoList.isEmpty) {
            return const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No information available',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => FadeTransition(
                opacity: _fadeAnimation,
                child: InfoCard(
                  info: provider.infoList[index],
                  index: index,
                  onTap: () =>
                      _navigateToDetail(context, provider.infoList[index]),
                ),
              ),
              childCount: provider.infoList.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Info info) {
    context.read<AdmobProvider>().onRouteChanged();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModernInfoDetailView(info: info),
      ),
    );
  }
}

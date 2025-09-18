import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/feature/view/quiz/modern_quiz_home.dart';
import 'package:elements_app/feature/view/puzzles/puzzles_home_view.dart';
import 'package:elements_app/feature/view/puzzles/trivia_center_view.dart';
import 'package:elements_app/feature/view/home/home_view.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';

class TestsHomeView extends StatelessWidget {
  TestsHomeView({super.key});

  final PatternService _pattern = PatternService();

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return AppScaffold(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeView()),
            (route) => false,
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBarConfigs.custom(
            theme: AppBarVariant.quiz,
            style: AppBarStyle.gradient,
            title: isTr ? 'Oyunlar' : 'Games',
          ).toAppBar(),
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _pattern.getPatternPainter(
                    type: PatternType.atomic,
                    color: Colors.white,
                    opacity: 0.03,
                  ),
                ),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Intro banner
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.darkBlue.withValues(alpha: 0.85),
                            AppColors.darkBlue.withValues(alpha: 0.65),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.steelBlue.withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.videogame_asset_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isTr ? 'Oyunlar' : 'Games',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isTr
                                      ? 'Öğrenirken eğlen, kategorini seç ve başla.'
                                      : 'Have fun while learning. Pick a category and start.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    const BannerAdsWidget(showLoadingIndicator: true),
                    const SizedBox(height: 16),
                    _buildCard(
                      context,
                      title: isTr ? 'Quizler' : 'Quizzes',
                      subtitle: isTr ? 'Bilgi Testleri' : 'Knowledge Quizzes',
                      iconSvg: AssetConstants.instance.svgGameThree,
                      color: AppColors.pink,
                      shadow: AppColors.shPink,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModernQuizHome(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      context,
                      title: isTr ? 'Bulmacalar' : 'Puzzles',
                      subtitle: isTr
                          ? 'Kelime, eşleştirme ve daha fazlası'
                          : 'Word, matching and more',
                      iconSvg: AssetConstants.instance.svgGameThree,
                      color: AppColors.steelBlue,
                      shadow: AppColors.shSteelBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PuzzlesHomeView()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      context,
                      title: isTr ? 'Element Trivia' : 'Element Trivia',
                      subtitle: isTr
                          ? 'Kategori seç ve trivia çöz'
                          : 'Pick a category and play',
                      iconSvg: AssetConstants.instance.svgGameThree,
                      color: AppColors.turquoise,
                      shadow: AppColors.shTurquoise,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TriviaCenterView()),
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String iconSvg,
    required Color color,
    required Color shadow,
    required VoidCallback onTap,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadow.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.extension_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip(isTr ? 'Popüler' : 'Popular', Colors.white),
                        const SizedBox(width: 8),
                        _chip(isTr ? 'Zorlayıcı' : 'Challenging', Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  isTr ? 'Başla' : 'Start',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

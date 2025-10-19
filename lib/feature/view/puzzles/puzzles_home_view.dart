import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/view/puzzles/word_puzzle_view.dart';
import 'package:elements_app/feature/view/puzzles/matching_puzzle_view.dart';
import 'package:elements_app/feature/view/puzzles/puzzles_statistics_view.dart';
import 'package:elements_app/feature/view/puzzles/puzzles_achievements_view.dart';
import 'package:elements_app/product/widget/common/center_quick_actions_row.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';

class PuzzlesHomeView extends StatelessWidget {
  final bool first20Only;

  PuzzlesHomeView({super.key, this.first20Only = false});
  final PatternService _pattern = PatternService();

  AppBar _buildModernAppBar(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
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
              Icons.extension,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? 'Bulmaca Merkezi' : 'Puzzles Center',
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

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
        appBar: _buildModernAppBar(context),
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
                  CenterQuickActionsRow(
                    statisticsTitle: isTr ? 'İstatistikler' : 'Statistics',
                    statisticsSubtitle: isTr ? 'Genel görünüm' : 'Overview',
                    statisticsGradient: [
                      AppColors.purple.withValues(alpha: 0.9),
                      AppColors.pink.withValues(alpha: 0.7),
                    ],
                    onStatisticsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PuzzlesStatisticsView(),
                        ),
                      );
                    },
                    achievementsTitle: isTr ? 'Başarılar' : 'Achievements',
                    achievementsSubtitle: isTr ? 'Rozetler' : 'Badges',
                    achievementsGradient: [
                      AppColors.steelBlue.withValues(alpha: 0.6),
                      AppColors.darkBlue.withValues(alpha: 0.6),
                    ],
                    onAchievementsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PuzzlesAchievementsView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const BannerAdsWidget(showLoadingIndicator: true),
                  const SizedBox(height: 8),
                  _modernCenterSeparator(context),

                  _buildCard(
                    context,
                    icon: Icons.spellcheck,
                    title: isTr ? 'Kelime Bulmacası' : 'Word Puzzle',
                    subtitle: isTr
                        ? 'Karışık harflerden doğru elementi oluştur'
                        : 'Unscramble letters to form the element',
                    color: AppColors.turquoise,
                    onTap: () async {
                      await context.read<PuzzleProvider>().startWordPuzzle(
                        turkish: isTr,
                      );
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WordPuzzleView(first20Only: first20Only),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    context,
                    icon: Icons.compare_arrows,
                    title: isTr ? 'Eşleştirme Oyunu' : 'Matching Game',
                    subtitle: isTr
                        ? 'Sembol ve isimleri doğru eşleştir'
                        : 'Match symbols with element names',
                    color: AppColors.steelBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MatchingPuzzleView(first20Only: first20Only),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Element Trivia moved to Games section
                  const SizedBox(height: 12),
                  _buildCard(
                    context,
                    icon: Icons.grid_on,
                    title: isTr ? 'Çapraz Bulmaca' : 'Crossword',
                    subtitle: '',
                    color: AppColors.pink,
                    isSoon: true,
                    soonText: isTr ? 'ÇOK YAKINDA' : 'COMING SOON',
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    context,
                    icon: Icons.table_rows,
                    title: isTr
                        ? 'Periyodik Tablo Yerleştirme'
                        : 'Periodic Placement',
                    subtitle: '',
                    color: AppColors.turquoise,
                    isSoon: true,
                    soonText: isTr ? 'ÇOK YAKINDA' : 'COMING SOON',
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernCenterSeparator(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBlue.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              isTr ? 'Oyunlar' : 'Games',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.86),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
    bool isSoon = false,
    String? soonText,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15), // Element color background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.4), // Element color border
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3), // Element color shadow
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
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.6), // More prominent color
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
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
                  if (isSoon)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.yellow.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        soonText ?? (isTr ? 'ÇOK YAKINDA' : 'COMING SOON'),
                        style: const TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
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
                      if (!isSoon) _chip(isTr ? 'Popüler' : 'Popular'),
                      if (!isSoon) const SizedBox(width: 8),
                      if (!isSoon) _chip(isTr ? 'Zorlu' : 'Challenging'),
                    ],
                  ),
                ],
              ),
            ),
            if (!isSoon)
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
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
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

  // Deprecated cards removed in favor of quick actions row
}

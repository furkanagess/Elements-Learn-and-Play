import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/view/puzzles/element_trivia_view.dart';
import 'package:elements_app/feature/view/trivia/trivia_statistics_view.dart';
import 'package:elements_app/feature/view/trivia/trivia_achievements_view.dart';
import 'package:elements_app/product/widget/common/center_quick_actions_row.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:elements_app/feature/model/puzzle/puzzle_models.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';

class TriviaCenterView extends StatelessWidget {
  final bool first20Only;

  TriviaCenterView({super.key, this.first20Only = false});
  final PatternService _pattern = PatternService();

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.quiz,
          style: AppBarStyle.gradient,
          title: isTr ? 'Trivia Merkezi' : 'Trivia Center',
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
                          builder: (context) => const TriviaStatisticsView(),
                        ),
                      );
                    },
                    achievementsTitle: isTr ? 'Başarılar' : 'Achievements',
                    achievementsSubtitle: isTr ? 'Rozetler' : 'Badges',
                    achievementsGradient: [
                      AppColors.steelBlue.withValues(alpha: 0.6),
                      AppColors.darkBlue.withValues(alpha: 0.6),
                    ],
                    achievementsFooter: Consumer<PuzzleProvider>(
                      builder: (ctx, provider, _) {
                        final word = provider.getProgress(PuzzleType.word);
                        final matching = provider.getProgress(
                          PuzzleType.matching,
                        );
                        final (int earnedW, int totalW) =
                            _computeBadgesOverview(word);
                        final (int earnedM, int totalM) =
                            _computeBadgesOverview(matching);
                        final earned = earnedW + earnedM;
                        final total = totalW + totalM;
                        return MiniChip(text: '$earned/$total');
                      },
                    ),
                    onAchievementsTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TriviaAchievementsView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  const BannerAdsWidget(showLoadingIndicator: true),
                  const SizedBox(height: 8),
                  _modernCenterSeparator(context),
                  _categoryCard(
                    context,
                    icon: Icons.category,
                    color: AppColors.glowGreen,
                    title: isTr ? 'Sınıflandırma' : 'Classification',
                    subtitle: isTr
                        ? 'Element kategorileri hakkında sorular'
                        : 'Questions about element categories',
                    allowedTypes: const [0],
                  ),
                  const SizedBox(height: 12),
                  _categoryCard(
                    context,
                    icon: Icons.scale,
                    color: AppColors.yellow,
                    title: isTr ? 'Atom Ağırlığı' : 'Atomic Weight',
                    subtitle: isTr
                        ? 'Atom ağırlıkları hakkında sorular'
                        : 'Questions about atomic weights',
                    allowedTypes: const [1],
                  ),
                  const SizedBox(height: 12),
                  _categoryCard(
                    context,
                    icon: Icons.timeline,
                    color: AppColors.pink,
                    title: isTr ? 'Periyot' : 'Period',
                    subtitle: isTr
                        ? 'Periyot yerleşimleri hakkında sorular'
                        : 'Questions about period placements',
                    allowedTypes: const [2],
                  ),
                  const SizedBox(height: 12),
                  _categoryCard(
                    context,
                    icon: Icons.description,
                    color: AppColors.turquoise,
                    title: isTr ? 'Açıklama' : 'Description',
                    subtitle: isTr
                        ? 'Element açıklamalarına göre tahmin et'
                        : 'Guess by element descriptions',
                    allowedTypes: const [3],
                  ),
                  const SizedBox(height: 12),
                  _categoryCard(
                    context,
                    icon: Icons.build,
                    color: AppColors.steelBlue,
                    title: isTr ? 'Kullanım' : 'Uses',
                    subtitle: isTr
                        ? 'Kullanım alanlarına göre tahmin et'
                        : 'Guess by usage',
                    allowedTypes: const [4],
                  ),
                  const SizedBox(height: 12),
                  _categoryCard(
                    context,
                    icon: Icons.source,
                    color: AppColors.powderRed,
                    title: isTr ? 'Kaynak' : 'Source',
                    subtitle: isTr
                        ? 'Kaynak bilgilerine göre tahmin et'
                        : 'Guess by source info',
                    allowedTypes: const [5],
                  ),
                  const SizedBox(height: 20),
                  _categoryCard(
                    context,
                    icon: Icons.all_inbox,
                    color: AppColors.purple,
                    title: isTr ? 'Karışık' : 'Mixed',
                    subtitle: isTr
                        ? 'Tüm kategorilerden karışık sorular'
                        : 'Mixed questions from all categories',
                    allowedTypes: const [],
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

  Widget _categoryCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required List<int> allowedTypes,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ElementTriviaView(
                allowedTypes: allowedTypes,
                first20Only: first20Only,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
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
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
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
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _chip(isTr ? 'Kategori' : 'Category'),
                        const SizedBox(width: 8),
                        _chip(isTr ? 'Trivia' : 'Trivia'),
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
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
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

  Widget _buildQuickActionsRow(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Row(
      children: [
        Expanded(
          child: _squareAction(
            context,
            title: isTr ? 'İstatistikler' : 'Statistics',
            subtitle: isTr ? 'Genel görünüm' : 'Overview',
            icon: Icons.analytics_rounded,
            gradientColors: [
              AppColors.purple.withValues(alpha: 0.9),
              AppColors.pink.withValues(alpha: 0.7),
            ],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TriviaStatisticsView(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _squareAction(
            context,
            title: isTr ? 'Başarılar' : 'Achievements',
            subtitle: isTr ? 'Rozetler' : 'Badges',
            icon: Icons.emoji_events_rounded,
            gradientColors: [
              AppColors.steelBlue.withValues(alpha: 0.6),
              AppColors.darkBlue.withValues(alpha: 0.6),
            ],
            footerBuilder: (ctx) => Consumer<PuzzleProvider>(
              builder: (ctx, provider, _) {
                final word = provider.getProgress(PuzzleType.word);
                final matching = provider.getProgress(PuzzleType.matching);
                final (int earnedW, int totalW) = _computeBadgesOverview(word);
                final (int earnedM, int totalM) = _computeBadgesOverview(
                  matching,
                );
                final earned = earnedW + earnedM;
                final total = totalW + totalM;
                return _miniChip(text: '$earned/$total');
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TriviaAchievementsView(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _squareAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    String? subtitle,
    Widget Function(BuildContext context)? footerBuilder,
  }) {
    final pattern = _pattern;
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: pattern.getPatternPainter(
                        type: PatternType.molecular,
                        color: Colors.white,
                        opacity: 0.05,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                              width: 1,
                            ),
                          ),
                          child: Icon(icon, color: AppColors.white, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                        if (footerBuilder != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: footerBuilder(context),
                          ),
                        ],
                      ],
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

  Widget _miniChip({required String text}) {
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
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  (int earned, int total) _computeBadgesOverview(PuzzleProgress progress) {
    final totalWins = progress.totalWins;
    final totalPlays = progress.totalPlays;
    final bestSec = progress.bestTime.inSeconds;
    final avgSec = totalPlays == 0
        ? 0
        : (progress.totalTime.inSeconds / totalPlays).round();

    int earned = 0;
    int total = 0;

    for (final t in [1, 5, 10, 25]) {
      total += 1;
      if (totalWins >= t) earned += 1;
    }
    for (final t in [10, 25, 50]) {
      total += 1;
      if (totalPlays >= t) earned += 1;
    }
    for (final t in [30, 20, 15]) {
      total += 1;
      if (bestSec > 0 && bestSec < t) earned += 1;
    }
    total += 1; // average < 40s
    if (avgSec > 0 && avgSec < 40) earned += 1;

    return (earned, total);
  }

  // (old full-width cards removed)
  Widget _buildStatisticsCard(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TriviaStatisticsView(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.purple.withValues(alpha: 0.9),
                AppColors.pink.withValues(alpha: 0.7),
                AppColors.turquoise.withValues(alpha: 0.5),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isTr ? 'İstatistikler' : 'Statistics',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTr
                          ? 'Performansını görüntüle, en iyi sürelerini incele'
                          : 'View your performance and best times',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (old full-width cards removed)
  Widget _buildAchievementsEntryCard(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TriviaAchievementsView(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.steelBlue.withValues(alpha: 0.25),
                AppColors.darkBlue.withValues(alpha: 0.35),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Başarılar' : 'Achievements',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Consumer<PuzzleProvider>(
                      builder: (context, provider, child) {
                        final word = provider.getProgress(PuzzleType.word);
                        final matching = provider.getProgress(
                          PuzzleType.matching,
                        );
                        // Mirrors puzzles home: basic summary
                        int earned = 0;
                        final total = 3;
                        final totalWins = word.totalWins + matching.totalWins;
                        final hasFirstWin = totalWins > 0;
                        final hasFiveWins = totalWins >= 5;
                        final fastWord =
                            word.bestTime != Duration.zero &&
                            word.bestTime.inSeconds < 30;
                        final fastMatching =
                            matching.bestTime != Duration.zero &&
                            matching.bestTime.inSeconds < 30;
                        final hasFast = fastWord || fastMatching;
                        earned += hasFirstWin ? 1 : 0;
                        earned += hasFiveWins ? 1 : 0;
                        earned += hasFast ? 1 : 0;
                        return Text(
                          isTr
                              ? 'Kazanılan rozetler: $earned/$total'
                              : 'Badges earned: $earned/$total',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.white.withValues(alpha: 0.9),
                  size: 16,
                ),
              ),
            ],
          ),
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
}

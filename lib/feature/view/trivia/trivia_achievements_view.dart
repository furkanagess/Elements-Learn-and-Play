import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/provider/trivia_provider.dart';

class TriviaAchievementsView extends StatefulWidget {
  const TriviaAchievementsView({super.key});

  @override
  State<TriviaAchievementsView> createState() => _TriviaAchievementsViewState();
}

class _TriviaAchievementsViewState extends State<TriviaAchievementsView>
    with TickerProviderStateMixin {
  final PatternService _patternService = PatternService();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.quiz,
          style: AppBarStyle.gradient,
          title: isTr ? 'Başarılar' : 'Achievements',
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
                onPressed: () => _showClearAchievementsDialog(context),
              ),
            ),
          ],
        ).toAppBar(),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Consumer<TriviaProvider>(
                    builder: (context, provider, child) {
                      // Build badges per category using category stats
                      final categories =
                          <(TriviaCategory c, String title, Color color)>[
                            (
                              TriviaCategory.classification,
                              isTr ? 'Sınıflandırma' : 'Classification',
                              Colors.teal,
                            ),
                            (
                              TriviaCategory.weight,
                              isTr ? 'Atom Ağırlığı' : 'Atomic Weight',
                              Colors.amber,
                            ),
                            (
                              TriviaCategory.period,
                              isTr ? 'Periyot' : 'Period',
                              Colors.pinkAccent,
                            ),
                            (
                              TriviaCategory.description,
                              isTr ? 'Açıklama' : 'Description',
                              Colors.cyan,
                            ),
                            (
                              TriviaCategory.usage,
                              isTr ? 'Kullanım' : 'Uses',
                              Colors.lightGreen,
                            ),
                            (
                              TriviaCategory.source,
                              isTr ? 'Kaynak' : 'Source',
                              Colors.deepOrangeAccent,
                            ),
                            (
                              TriviaCategory.mixed,
                              isTr ? 'Karışık' : 'Mixed',
                              Colors.deepPurpleAccent,
                            ),
                          ];

                      final strips = <Widget>[];
                      int totalEarned = 0;
                      int totalBadges = 0;

                      for (final entry in categories) {
                        final category = entry.$1;
                        final title = entry.$2;
                        final color = entry.$3;
                        final stats = provider.getCategoryStats(category);
                        final badges = _buildAchievementsForCategory(
                          isTr: isTr,
                          stats: stats,
                        );
                        totalEarned += badges.where((b) => b.earned).length;
                        totalBadges += badges.length;
                        strips.addAll([
                          _buildModernBadgeStrip(
                            context,
                            isTr: isTr,
                            title: title,
                            color: color,
                            badges: badges,
                            category: category,
                          ),
                          const SizedBox(height: 16),
                        ]);
                      }

                      final progress = totalBadges == 0
                          ? 0.0
                          : totalEarned / totalBadges;

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          _summaryCard(
                            isTr,
                            totalEarned,
                            totalBadges,
                            progress,
                          ),
                          const SizedBox(height: 20),
                          _buildModernHint(isTr),
                          const SizedBox(height: 16),
                          ...strips,
                          const SizedBox(height: 100),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHint(bool isTr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.turquoise.withValues(alpha: 0.15),
            AppColors.purple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.turquoise.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.turquoise.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isTr
                  ? 'Rozetlere dokunarak ilerlemeni ve detayları gör'
                  : 'Tap badges to view progress and details',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(bool isTr, int earned, int total, double progress) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.9),
            AppColors.pink.withValues(alpha: 0.7),
            AppColors.turquoise.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTr ? 'Başarılarım' : 'My Achievements',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isTr
                            ? 'Kazanılan rozetler: $earned/$total'
                            : 'Badges earned: $earned/$total',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTr ? 'Genel İlerleme' : 'Overall Progress',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TriviaBadge> _buildAchievementsForCategory({
    required bool isTr,
    required TriviaCategoryStats stats,
  }) {
    final wins = stats.totalWins;
    final plays = stats.totalGamesPlayed;
    final bestSec = stats.bestTime.inSeconds;

    final List<_TriviaBadge> badges = [];

    // Wins milestones per category
    for (final t in [1, 3, 5, 10]) {
      badges.add(
        _TriviaBadge(
          icon: Icons.star,
          titleTr: t == 1 ? 'İlk Zafer' : '$t Zafer',
          titleEn: t == 1 ? 'First Win' : '$t Wins',
          descTr: t == 1
              ? 'Bu kategoride ilk kez kazan'
              : 'Bu kategoride $t kez kazan',
          descEn: t == 1
              ? 'Win first time in this category'
              : 'Win $t times in this category',
          progressLabel: '$wins/$t',
          progress: t == 0 ? 0 : wins / t,
          earned: wins >= t,
        ),
      );
    }

    // Plays milestones per category
    for (final t in [5, 10, 20]) {
      badges.add(
        _TriviaBadge(
          icon: Icons.videogame_asset_rounded,
          titleTr: '$t Oyun',
          titleEn: '$t Plays',
          descTr: 'Bu kategoride $t oyun oyna',
          descEn: 'Play $t games in this category',
          progressLabel: '$plays/$t',
          progress: t == 0 ? 0 : plays / t,
          earned: plays >= t,
        ),
      );
    }

    // Speed per category
    for (final t in [90, 60, 30]) {
      final ok = bestSec > 0 && bestSec < t;
      badges.add(
        _TriviaBadge(
          icon: Icons.bolt,
          titleTr: t == 90 ? 'Hızlanan' : (t == 60 ? 'Hızlı' : 'Şimşek'),
          titleEn: t == 90 ? 'Warming Up' : (t == 60 ? 'Fast' : 'Lightning'),
          descTr: 'En iyi süreyi ${t}s altına indir',
          descEn: 'Get best time under ${t}s',
          progressLabel: bestSec <= 0
              ? (isTr ? 'Henüz süre yok' : 'No time yet')
              : '${bestSec}s/${t}s',
          progress: bestSec <= 0 ? 0 : (t / bestSec).clamp(0, 1).toDouble(),
          earned: ok,
        ),
      );
    }

    return badges;
  }

  Widget _buildModernBadgeStrip(
    BuildContext context, {
    required bool isTr,
    required String title,
    required Color color,
    required List<_TriviaBadge> badges,
    required TriviaCategory category,
  }) {
    final earnedCount = badges.where((b) => b.earned).length;
    final progress = badges.isEmpty ? 0.0 : (earnedCount / badges.length);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
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
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getRandomPatternPainter(
                  seed: title.hashCode,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.3),
                              color.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.question_answer,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTr
                                  ? 'Kazanılan: $earnedCount/${badges.length}'
                                  : 'Earned: $earnedCount/${badges.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        color.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: badges.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) =>
                          _badgeTileHorizontal(badges[index], color, isTr),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // View All Button
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _navigateToTriviaCategoryAchievements(category, isTr);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withValues(alpha: 0.3),
                                color.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isTr ? 'Tümünü Gör' : 'View All',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: AppColors.white.withValues(alpha: 0.8),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeTileHorizontal(_TriviaBadge badge, Color color, bool isTr) {
    final earned = badge.earned;
    final progress = badge.progress;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showBadgeDetail(badge, color, isTr);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: earned
                  ? [
                      Colors.amber.withValues(alpha: 0.3),
                      Colors.orange.withValues(alpha: 0.2),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: earned
                  ? Colors.amber.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isTr ? badge.titleTr : badge.titleEn,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: earned
                            ? Colors.lightGreenAccent.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: earned
                              ? Colors.lightGreenAccent.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        earned ? Icons.check_circle : Icons.lock_outline,
                        size: 14,
                        color: earned
                            ? Colors.lightGreenAccent
                            : Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            value: earned ? 1 : progress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              earned
                                  ? Colors.lightGreenAccent
                                  : Colors.amberAccent,
                            ),
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: earned
                                  ? [
                                      Colors.amber.withValues(alpha: 0.8),
                                      Colors.orange.withValues(alpha: 0.6),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.white.withValues(alpha: 0.08),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            badge.icon,
                            size: 18,
                            color: earned ? Colors.black : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Text(
                    isTr ? badge.descTr : badge.descEn,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBadgeDetail(_TriviaBadge badge, Color color, bool isTr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: badge.earned
                  ? [
                      AppColors.purple.withValues(alpha: 0.95),
                      AppColors.pink.withValues(alpha: 0.8),
                      AppColors.turquoise.withValues(alpha: 0.7),
                    ]
                  : [
                      AppColors.darkBlue.withValues(alpha: 0.95),
                      AppColors.steelBlue.withValues(alpha: 0.8),
                      AppColors.purple.withValues(alpha: 0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: badge.earned
                              ? [
                                  Colors.amber.withValues(alpha: 0.8),
                                  Colors.orange.withValues(alpha: 0.6),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        badge.icon,
                        color: badge.earned ? Colors.black : AppColors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTr ? badge.titleTr : badge.titleEn,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTr ? badge.descTr : badge.descEn,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badge.earned
                            ? Colors.lightGreenAccent.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: badge.earned
                              ? Colors.lightGreenAccent.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        badge.earned ? Icons.check_circle : Icons.lock_outline,
                        color: badge.earned
                            ? Colors.lightGreenAccent
                            : Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTr ? 'İlerleme' : 'Progress',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            badge.progressLabel,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: badge.earned ? 1 : badge.progress,
                          minHeight: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            badge.earned
                                ? Colors.lightGreenAccent
                                : Colors.amberAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToTriviaCategoryAchievements(
    TriviaCategory category,
    bool isTr,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TriviaCategoryAchievementsPage(category: category),
      ),
    );
  }

  void _showClearAchievementsDialog(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.powderRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.powderRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isTr ? 'Başarıları Temizle' : 'Clear Achievements',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          isTr
              ? 'Tüm trivia başarılarınız (ileri düzey rozet hesapları istatistiklere göre) sıfırlanacak. Emin misiniz?'
              : 'All your trivia achievements (derived from statistics) will reset. Are you sure?',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isTr ? 'İptal' : 'Cancel',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // For trivia, achievements are derived; clearing stats is enough
              context.read<TriviaProvider>().clearAll();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.powderRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              isTr ? 'Temizle' : 'Clear',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dedicated page to show all achievements for a specific trivia category
class TriviaCategoryAchievementsPage extends StatefulWidget {
  final TriviaCategory category;

  const TriviaCategoryAchievementsPage({super.key, required this.category});

  @override
  State<TriviaCategoryAchievementsPage> createState() =>
      _TriviaCategoryAchievementsPageState();
}

class _TriviaCategoryAchievementsPageState
    extends State<TriviaCategoryAchievementsPage>
    with TickerProviderStateMixin {
  final PatternService _patternService = PatternService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final provider = context.watch<TriviaProvider>();
    final stats = provider.getCategoryStats(widget.category);
    final badges = _buildAchievementsForCategory(isTr: isTr, stats: stats);
    final color = _getCategoryColor(widget.category);
    final earnedCount = badges.where((b) => b.earned).length;
    final progress = badges.isEmpty ? 0.0 : (earnedCount / badges.length);

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.quiz,
          style: AppBarStyle.gradient,
          title: isTr
              ? '${_getCategoryTitle(widget.category, isTr)} - Başarılar'
              : '${_getCategoryTitle(widget.category, isTr)} - Achievements',
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ).toAppBar(),
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildCategoryHeader(
                          isTr,
                          earnedCount,
                          badges.length,
                          progress,
                          color,
                        ),
                        const SizedBox(height: 20),
                        _buildAchievementsGrid(badges, isTr, color),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
    bool isTr,
    int earnedCount,
    int totalCount,
    double progress,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getRandomPatternPainter(
                  seed: widget.category.hashCode,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.3),
                              color.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.question_answer,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getCategoryTitle(widget.category, isTr),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTr
                                  ? 'Kazanılan rozetler: $earnedCount/$totalCount'
                                  : 'Badges earned: $earnedCount/$totalCount',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isTr ? 'Genel İlerleme' : 'Overall Progress',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              color.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsGrid(
    List<_TriviaBadge> badges,
    bool isTr,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTr ? 'Tüm Başarılar' : 'All Achievements',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            return _buildGridBadgeTile(badges[index], isTr, index, color);
          },
        ),
      ],
    );
  }

  Widget _buildGridBadgeTile(
    _TriviaBadge badge,
    bool isTr,
    int index,
    Color color,
  ) {
    final earned = badge.earned;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showBadgeDetail(badge, color, isTr);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: earned
                  ? [
                      Colors.amber.withValues(alpha: 0.3),
                      Colors.orange.withValues(alpha: 0.2),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: earned
                  ? Colors.amber.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              if (earned)
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 20,
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
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _patternService.getRandomPatternPainter(
                      seed: badge.titleTr.hashCode,
                      color: Colors.white,
                      opacity: 0.02,
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isTr ? badge.titleTr : badge.titleEn,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                shadows: earned
                                    ? [
                                        Shadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: earned
                                  ? Colors.lightGreenAccent.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: earned
                                    ? Colors.lightGreenAccent.withValues(
                                        alpha: 0.3,
                                      )
                                    : Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              earned ? Icons.check_circle : Icons.lock_outline,
                              size: 16,
                              color: earned
                                  ? Colors.lightGreenAccent
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Icon with progress ring
                      Center(
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress ring
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: earned
                                      ? 1
                                      : badge.progress.clamp(0, 1),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.1,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    earned
                                        ? Colors.lightGreenAccent
                                        : Colors.amberAccent,
                                  ),
                                ),
                              ),
                              // Icon container
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: earned
                                        ? [
                                            Colors.amber.withValues(alpha: 0.8),
                                            Colors.orange.withValues(
                                              alpha: 0.6,
                                            ),
                                          ]
                                        : [
                                            Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            Colors.white.withValues(
                                              alpha: 0.08,
                                            ),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  badge.icon,
                                  size: 20,
                                  color: earned
                                      ? Colors.black
                                      : AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      Expanded(
                        child: Text(
                          isTr ? badge.descTr : badge.descEn,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
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
  }

  void _showBadgeDetail(_TriviaBadge badge, Color color, bool isTr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: badge.earned
                  ? [
                      AppColors.purple.withValues(alpha: 0.95),
                      AppColors.pink.withValues(alpha: 0.8),
                      AppColors.turquoise.withValues(alpha: 0.7),
                    ]
                  : [
                      AppColors.darkBlue.withValues(alpha: 0.95),
                      AppColors.steelBlue.withValues(alpha: 0.8),
                      AppColors.purple.withValues(alpha: 0.7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: badge.earned
                              ? [
                                  Colors.amber.withValues(alpha: 0.8),
                                  Colors.orange.withValues(alpha: 0.6),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        badge.icon,
                        color: badge.earned ? Colors.black : AppColors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTr ? badge.titleTr : badge.titleEn,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTr ? badge.descTr : badge.descEn,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badge.earned
                            ? Colors.lightGreenAccent.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: badge.earned
                              ? Colors.lightGreenAccent.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        badge.earned ? Icons.check_circle : Icons.lock_outline,
                        color: badge.earned
                            ? Colors.lightGreenAccent
                            : Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isTr ? 'İlerleme' : 'Progress',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            badge.progressLabel,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: badge.earned ? 1 : badge.progress,
                          minHeight: 12,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            badge.earned
                                ? Colors.lightGreenAccent
                                : Colors.amberAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_TriviaBadge> _buildAchievementsForCategory({
    required bool isTr,
    required TriviaCategoryStats stats,
  }) {
    final wins = stats.totalWins;
    final plays = stats.totalGamesPlayed;
    final bestSec = stats.bestTime.inSeconds;

    final List<_TriviaBadge> badges = [];

    // Wins milestones per category
    for (final t in [1, 3, 5, 10]) {
      badges.add(
        _TriviaBadge(
          icon: Icons.star,
          titleTr: t == 1 ? 'İlk Zafer' : '$t Zafer',
          titleEn: t == 1 ? 'First Win' : '$t Wins',
          descTr: t == 1
              ? 'Bu kategoride ilk kez kazan'
              : 'Bu kategoride $t kez kazan',
          descEn: t == 1
              ? 'Win first time in this category'
              : 'Win $t times in this category',
          progressLabel: '$wins/$t',
          progress: t == 0 ? 0 : wins / t,
          earned: wins >= t,
        ),
      );
    }

    // Plays milestones per category
    for (final t in [5, 10, 20]) {
      badges.add(
        _TriviaBadge(
          icon: Icons.videogame_asset_rounded,
          titleTr: '$t Oyun',
          titleEn: '$t Plays',
          descTr: 'Bu kategoride $t oyun oyna',
          descEn: 'Play $t games in this category',
          progressLabel: '$plays/$t',
          progress: t == 0 ? 0 : plays / t,
          earned: plays >= t,
        ),
      );
    }

    // Speed per category
    for (final t in [90, 60, 30]) {
      final ok = bestSec > 0 && bestSec < t;
      badges.add(
        _TriviaBadge(
          icon: Icons.bolt,
          titleTr: t == 90 ? 'Hızlanan' : (t == 60 ? 'Hızlı' : 'Şimşek'),
          titleEn: t == 90 ? 'Warming Up' : (t == 60 ? 'Fast' : 'Lightning'),
          descTr: 'En iyi süreyi ${t}s altına indir',
          descEn: 'Get best time under ${t}s',
          progressLabel: bestSec <= 0
              ? (isTr ? 'Henüz süre yok' : 'No time yet')
              : '${bestSec}s/${t}s',
          progress: bestSec <= 0 ? 0 : (t / bestSec).clamp(0, 1).toDouble(),
          earned: ok,
        ),
      );
    }

    return badges;
  }

  Color _getCategoryColor(TriviaCategory category) {
    switch (category) {
      case TriviaCategory.classification:
        return Colors.teal;
      case TriviaCategory.weight:
        return Colors.amber;
      case TriviaCategory.period:
        return Colors.pinkAccent;
      case TriviaCategory.description:
        return Colors.cyan;
      case TriviaCategory.usage:
        return Colors.lightGreen;
      case TriviaCategory.source:
        return Colors.deepOrangeAccent;
      case TriviaCategory.mixed:
        return Colors.deepPurpleAccent;
    }
  }

  String _getCategoryTitle(TriviaCategory category, bool isTr) {
    switch (category) {
      case TriviaCategory.classification:
        return isTr ? 'Sınıflandırma' : 'Classification';
      case TriviaCategory.weight:
        return isTr ? 'Atom Ağırlığı' : 'Atomic Weight';
      case TriviaCategory.period:
        return isTr ? 'Periyot' : 'Period';
      case TriviaCategory.description:
        return isTr ? 'Açıklama' : 'Description';
      case TriviaCategory.usage:
        return isTr ? 'Kullanım' : 'Uses';
      case TriviaCategory.source:
        return isTr ? 'Kaynak' : 'Source';
      case TriviaCategory.mixed:
        return isTr ? 'Karışık' : 'Mixed';
    }
  }
}

class _TriviaBadge {
  final IconData icon;
  final String titleTr;
  final String titleEn;
  final String descTr;
  final String descEn;
  final String progressLabel;
  final double progress; // 0..1
  final bool earned;

  _TriviaBadge({
    required this.icon,
    required this.titleTr,
    required this.titleEn,
    required this.descTr,
    required this.descEn,
    required this.progressLabel,
    required this.progress,
    required this.earned,
  });
}

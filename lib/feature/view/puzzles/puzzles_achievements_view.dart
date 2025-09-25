import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:elements_app/feature/model/puzzle/puzzle_models.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/product/widget/premium/premium_overlay.dart';

class PuzzlesAchievementsView extends StatefulWidget {
  const PuzzlesAchievementsView({super.key});

  @override
  State<PuzzlesAchievementsView> createState() =>
      _PuzzlesAchievementsViewState();
}

class _PuzzlesAchievementsViewState extends State<PuzzlesAchievementsView>
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
                  child: Consumer<PuzzleProvider>(
                    builder: (context, provider, child) {
                      final word = provider.getProgress(PuzzleType.word);
                      final matching = provider.getProgress(
                        PuzzleType.matching,
                      );

                      final wordBadges = _buildBadgesFor(
                        progress: word,
                        type: PuzzleType.word,
                        isTr: isTr,
                      );
                      final matchingBadges = _buildBadgesFor(
                        progress: matching,
                        type: PuzzleType.matching,
                        isTr: isTr,
                      );

                      final totalEarned =
                          wordBadges.where((b) => b.earned).length +
                          matchingBadges.where((b) => b.earned).length;
                      final total = wordBadges.length + matchingBadges.length;
                      final overallProgress = total == 0
                          ? 0.0
                          : totalEarned / total;

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildSummaryCard(
                            isTr,
                            totalEarned,
                            total,
                            overallProgress,
                          ),
                          const SizedBox(height: 16),
                          _buildHint(isTr),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              // Word Puzzle - per-badge premium handled inside strip (3/11)
                              _buildModeStrip(
                                context,
                                isTr: isTr,
                                type: PuzzleType.word,
                                color: AppColors.glowGreen,
                                badges: wordBadges,
                              ),
                              const SizedBox(height: 16),
                              // Matching Game - per-badge premium handled inside strip (3/11)
                              _buildModeStrip(
                                context,
                                isTr: isTr,
                                type: PuzzleType.matching,
                                color: AppColors.yellow,
                                badges: matchingBadges,
                              ),
                            ],
                          ),
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

  Widget _buildSummaryCard(bool isTr, int earned, int total, double progress) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.05,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
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
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHint(bool isTr) {
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

  Widget _buildModeStrip(
    BuildContext context, {
    required bool isTr,
    required PuzzleType type,
    required Color color,
    required List<_PuzzleBadge> badges,
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
                  seed: type.hashCode,
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
                        child: Icon(
                          _typeIcon(type),
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
                              isTr ? _typeTitleTr(type) : _typeTitleEn(type),
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
                      itemBuilder: (context, index) {
                        final badge = badges[index];
                        final isPremiumBadge = _isPremiumBadge(badge, type);

                        if (isPremiumBadge) {
                          return PremiumOverlay(
                            child: _buildBadgeTile(badge, color, isTr),
                          );
                        } else {
                          return _buildBadgeTile(badge, color, isTr);
                        }
                      },
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
                          _navigateToPuzzleTypeAchievements(type, isTr);
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

  Widget _buildBadgeTile(_PuzzleBadge badge, Color color, bool isTr) {
    final progress = badge.progress;
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

  void _showBadgeDetail(_PuzzleBadge badge, Color color, bool isTr) {
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

  List<_PuzzleBadge> _buildBadgesFor({
    required PuzzleProgress progress,
    required PuzzleType type,
    required bool isTr,
  }) {
    final totalWins = progress.totalWins;
    final totalPlays = progress.totalPlays;
    final bestSec = progress.bestTime.inSeconds;
    final avgSec = totalPlays == 0
        ? 0
        : (progress.totalTime.inSeconds / totalPlays).round();

    List<_PuzzleBadge> badges = [];

    // Win milestones
    badges.addAll([
      _PuzzleBadge(
        id: '${type.name}_win_1',
        icon: Icons.emoji_events,
        titleTr: 'İlk Zafer',
        titleEn: 'First Win',
        descTr: 'Bu modda ilk kez kazan',
        descEn: 'Win for the first time in this mode',
        earned: totalWins >= 1,
        progress: (totalWins / 1).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/1',
      ),
      _PuzzleBadge(
        id: '${type.name}_wins_5',
        icon: Icons.star_border_rounded,
        titleTr: '5 Galibiyet',
        titleEn: '5 Wins',
        descTr: 'Bu modda 5 kez kazan',
        descEn: 'Win 5 times in this mode',
        earned: totalWins >= 5,
        progress: (totalWins / 5).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/5',
      ),
      _PuzzleBadge(
        id: '${type.name}_wins_10',
        icon: Icons.military_tech_rounded,
        titleTr: '10 Galibiyet',
        titleEn: '10 Wins',
        descTr: 'Bu modda 10 kez kazan',
        descEn: 'Win 10 times in this mode',
        earned: totalWins >= 10,
        progress: (totalWins / 10).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/10',
      ),
      _PuzzleBadge(
        id: '${type.name}_wins_25',
        icon: Icons.workspace_premium_rounded,
        titleTr: '25 Galibiyet',
        titleEn: '25 Wins',
        descTr: 'Bu modda 25 kez kazan',
        descEn: 'Win 25 times in this mode',
        earned: totalWins >= 25,
        progress: (totalWins / 25).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/25',
      ),
    ]);

    // Plays milestones
    badges.addAll([
      _PuzzleBadge(
        id: '${type.name}_plays_10',
        icon: Icons.videogame_asset_rounded,
        titleTr: '10 Oyun',
        titleEn: '10 Plays',
        descTr: 'Bu modda 10 kez oyna',
        descEn: 'Play this mode 10 times',
        earned: totalPlays >= 10,
        progress: (totalPlays / 10).clamp(0, 1).toDouble(),
        progressLabel: '${totalPlays}/10',
      ),
      _PuzzleBadge(
        id: '${type.name}_plays_25',
        icon: Icons.sports_esports_rounded,
        titleTr: '25 Oyun',
        titleEn: '25 Plays',
        descTr: 'Bu modda 25 kez oyna',
        descEn: 'Play this mode 25 times',
        earned: totalPlays >= 25,
        progress: (totalPlays / 25).clamp(0, 1).toDouble(),
        progressLabel: '${totalPlays}/25',
      ),
      _PuzzleBadge(
        id: '${type.name}_plays_50',
        icon: Icons.sports_esports_outlined,
        titleTr: '50 Oyun',
        titleEn: '50 Plays',
        descTr: 'Bu modda 50 kez oyna',
        descEn: 'Play this mode 50 times',
        earned: totalPlays >= 50,
        progress: (totalPlays / 50).clamp(0, 1).toDouble(),
        progressLabel: '${totalPlays}/50',
      ),
    ]);

    // Speed badges (best time)
    List<(int threshold, String idSfx, String tr, String en, IconData icon)>
    speedDefs = [
      (30, '30', 'Hızlı Parmaklar', 'Fast Fingers', Icons.flash_on_rounded),
      (20, '20', 'Şimşek Hız', 'Lightning Fast', Icons.bolt_rounded),
      (15, '15', 'Işık Hızında', 'Light Speed', Icons.bolt_outlined),
    ];
    for (final def in speedDefs) {
      final thresh = def.$1;
      badges.add(
        _PuzzleBadge(
          id: '${type.name}_fast_${def.$2}',
          icon: def.$5,
          titleTr: def.$3,
          titleEn: def.$4,
          descTr: 'En iyi süren ${thresh}s altına düşsün',
          descEn: 'Get best time under ${thresh}s',
          earned: bestSec > 0 && bestSec < thresh,
          progress: bestSec <= 0
              ? 0
              : (thresh / bestSec).clamp(0, 1).toDouble(),
          progressLabel: bestSec <= 0
              ? (isTr ? 'Henüz süre yok' : 'No time yet')
              : '${bestSec}s/${thresh}s',
        ),
      );
    }

    // Average time badge
    const int avgThreshold = 40;
    badges.add(
      _PuzzleBadge(
        id: '${type.name}_avg_${avgThreshold}',
        icon: Icons.timer_rounded,
        titleTr: 'Seri Hız',
        titleEn: 'Consistent Speed',
        descTr: 'Ortalama süreni ${avgThreshold}s altına indir',
        descEn: 'Reduce your average time below ${avgThreshold}s',
        earned: avgSec > 0 && avgSec < avgThreshold,
        progress: avgSec <= 0
            ? 0
            : (avgThreshold / avgSec).clamp(0, 1).toDouble(),
        progressLabel: avgSec <= 0 ? '—' : '${avgSec}s/${avgThreshold}s',
      ),
    );

    return badges;
  }

  IconData _typeIcon(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return Icons.spellcheck;
      case PuzzleType.matching:
        return Icons.compare_arrows;
      case PuzzleType.crossword:
        return Icons.grid_on;
      case PuzzleType.placement:
        return Icons.table_rows;
    }
  }

  String _typeTitleTr(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return 'Kelime Bulmacası';
      case PuzzleType.matching:
        return 'Eşleştirme Oyunu';
      case PuzzleType.crossword:
        return 'Çapraz Bulmaca';
      case PuzzleType.placement:
        return 'Tablo Yerleştirme';
    }
  }

  String _typeTitleEn(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return 'Word Puzzle';
      case PuzzleType.matching:
        return 'Matching Game';
      case PuzzleType.crossword:
        return 'Crossword';
      case PuzzleType.placement:
        return 'Periodic Placement';
    }
  }

  void _navigateToPuzzleTypeAchievements(PuzzleType type, bool isTr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PuzzleTypeAchievementsPage(puzzleType: type),
      ),
    );
  }

  bool _isPremiumBadge(_PuzzleBadge badge, PuzzleType type) {
    // Her puzzle türü için %30'u premium (11 başarımın 3'ü)
    final premiumBadgeIndices = _getPremiumBadgeIndices(type);
    final badgeIndex =
        badge.id.hashCode % 11; // 11 başarım olduğunu varsayıyoruz
    return premiumBadgeIndices.contains(badgeIndex);
  }

  List<int> _getPremiumBadgeIndices(PuzzleType type) {
    // Her puzzle türü için farklı premium badge indeksleri
    switch (type) {
      case PuzzleType.word:
        return [0, 4, 8]; // 3/11 = %27.3
      case PuzzleType.matching:
        return [1, 5, 9]; // 3/11 = %27.3
      case PuzzleType.crossword:
        return [2, 6, 10]; // 3/11 = %27.3
      case PuzzleType.placement:
        return [3, 7, 11]; // 3/11 = %27.3
    }
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
              child: Icon(
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
              ? 'Tüm bulmaca başarılarınız silinecek. Bu işlem geri alınamaz. Emin misiniz?'
              : 'All your puzzle achievements will be deleted. This action cannot be undone. Are you sure?',
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
              context.read<PuzzleProvider>().clearAllProgress();
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

/// Dedicated page to show all achievements for a specific puzzle type
class PuzzleTypeAchievementsPage extends StatefulWidget {
  final PuzzleType puzzleType;

  const PuzzleTypeAchievementsPage({super.key, required this.puzzleType});

  @override
  State<PuzzleTypeAchievementsPage> createState() =>
      _PuzzleTypeAchievementsPageState();
}

class _PuzzleTypeAchievementsPageState extends State<PuzzleTypeAchievementsPage>
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
    final provider = context.watch<PuzzleProvider>();
    final progress = provider.getProgress(widget.puzzleType);
    final badges = _buildBadgesFor(
      progress: progress,
      type: widget.puzzleType,
      isTr: isTr,
    );
    final color = _getPuzzleTypeColor(widget.puzzleType);
    final earnedCount = badges.where((b) => b.earned).length;
    final progressPercent = badges.isEmpty
        ? 0.0
        : (earnedCount / badges.length);

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.quiz,
          style: AppBarStyle.gradient,
          title: isTr
              ? '${_typeTitleTr(widget.puzzleType)} - Başarılar'
              : '${_typeTitleEn(widget.puzzleType)} - Achievements',
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
                        _buildPuzzleTypeHeader(
                          isTr,
                          earnedCount,
                          badges.length,
                          progressPercent,
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

  Widget _buildPuzzleTypeHeader(
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
                  seed: widget.puzzleType.hashCode,
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
                        child: Icon(
                          _typeIcon(widget.puzzleType),
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
                              isTr
                                  ? _typeTitleTr(widget.puzzleType)
                                  : _typeTitleEn(widget.puzzleType),
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
    List<_PuzzleBadge> badges,
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
            final badge = badges[index];
            final isPremiumBadge = _isPremiumBadge(badge, widget.puzzleType);

            if (isPremiumBadge) {
              return PremiumOverlay(
                child: _buildGridBadgeTile(badge, isTr, index, color),
              );
            } else {
              return _buildGridBadgeTile(badge, isTr, index, color);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGridBadgeTile(
    _PuzzleBadge badge,
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
                      seed: badge.id.hashCode,
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

  void _showBadgeDetail(_PuzzleBadge badge, Color color, bool isTr) {
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

  List<_PuzzleBadge> _buildBadgesFor({
    required PuzzleProgress progress,
    required PuzzleType type,
    required bool isTr,
  }) {
    final totalWins = progress.totalWins;
    final totalPlays = progress.totalPlays;
    final bestSec = progress.bestTime.inSeconds;
    final avgSec = totalPlays == 0
        ? 0
        : (progress.totalTime.inSeconds / totalPlays).round();

    List<_PuzzleBadge> badges = [];

    // Win milestones
    badges.addAll([
      _PuzzleBadge(
        id: '${type.name}_win_1',
        icon: Icons.emoji_events,
        titleTr: 'İlk Zafer',
        titleEn: 'First Win',
        descTr: 'Bu modda ilk kez kazan',
        descEn: 'Win for the first time in this mode',
        earned: totalWins >= 1,
        progress: (totalWins / 1).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/1',
      ),
      _PuzzleBadge(
        id: '${type.name}_wins_5',
        icon: Icons.star_border_rounded,
        titleTr: '5 Galibiyet',
        titleEn: '5 Wins',
        descTr: 'Bu modda 5 kez kazan',
        descEn: 'Win 5 times in this mode',
        earned: totalWins >= 5,
        progress: (totalWins / 5).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/5',
      ),
      _PuzzleBadge(
        id: '${type.name}_wins_10',
        icon: Icons.military_tech_rounded,
        titleTr: '10 Galibiyet',
        titleEn: '10 Wins',
        descTr: 'Bu modda 10 kez kazan',
        descEn: 'Win 10 times in this mode',
        earned: totalWins >= 10,
        progress: (totalWins / 10).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/10',
      ),
      _PuzzleBadge(
        id: '${type.name}_wins_25',
        icon: Icons.workspace_premium_rounded,
        titleTr: '25 Galibiyet',
        titleEn: '25 Wins',
        descTr: 'Bu modda 25 kez kazan',
        descEn: 'Win 25 times in this mode',
        earned: totalWins >= 25,
        progress: (totalWins / 25).clamp(0, 1).toDouble(),
        progressLabel: '${totalWins}/25',
      ),
    ]);

    // Plays milestones
    badges.addAll([
      _PuzzleBadge(
        id: '${type.name}_plays_10',
        icon: Icons.videogame_asset_rounded,
        titleTr: '10 Oyun',
        titleEn: '10 Plays',
        descTr: 'Bu modda 10 kez oyna',
        descEn: 'Play this mode 10 times',
        earned: totalPlays >= 10,
        progress: (totalPlays / 10).clamp(0, 1).toDouble(),
        progressLabel: '${totalPlays}/10',
      ),
      _PuzzleBadge(
        id: '${type.name}_plays_25',
        icon: Icons.sports_esports_rounded,
        titleTr: '25 Oyun',
        titleEn: '25 Plays',
        descTr: 'Bu modda 25 kez oyna',
        descEn: 'Play this mode 25 times',
        earned: totalPlays >= 25,
        progress: (totalPlays / 25).clamp(0, 1).toDouble(),
        progressLabel: '${totalPlays}/25',
      ),
      _PuzzleBadge(
        id: '${type.name}_plays_50',
        icon: Icons.sports_esports_outlined,
        titleTr: '50 Oyun',
        titleEn: '50 Plays',
        descTr: 'Bu modda 50 kez oyna',
        descEn: 'Play this mode 50 times',
        earned: totalPlays >= 50,
        progress: (totalPlays / 50).clamp(0, 1).toDouble(),
        progressLabel: '${totalPlays}/50',
      ),
    ]);

    // Speed badges (best time)
    List<(int threshold, String idSfx, String tr, String en, IconData icon)>
    speedDefs = [
      (30, '30', 'Hızlı Parmaklar', 'Fast Fingers', Icons.flash_on_rounded),
      (20, '20', 'Şimşek Hız', 'Lightning Fast', Icons.bolt_rounded),
      (15, '15', 'Işık Hızında', 'Light Speed', Icons.bolt_outlined),
    ];
    for (final def in speedDefs) {
      final thresh = def.$1;
      badges.add(
        _PuzzleBadge(
          id: '${type.name}_fast_${def.$2}',
          icon: def.$5,
          titleTr: def.$3,
          titleEn: def.$4,
          descTr: 'En iyi süren ${thresh}s altına düşsün',
          descEn: 'Get best time under ${thresh}s',
          earned: bestSec > 0 && bestSec < thresh,
          progress: bestSec <= 0
              ? 0
              : (thresh / bestSec).clamp(0, 1).toDouble(),
          progressLabel: bestSec <= 0
              ? (isTr ? 'Henüz süre yok' : 'No time yet')
              : '${bestSec}s/${thresh}s',
        ),
      );
    }

    // Average time badge
    const int avgThreshold = 40;
    badges.add(
      _PuzzleBadge(
        id: '${type.name}_avg_${avgThreshold}',
        icon: Icons.timer_rounded,
        titleTr: 'Seri Hız',
        titleEn: 'Consistent Speed',
        descTr: 'Ortalama süreni ${avgThreshold}s altına indir',
        descEn: 'Reduce your average time below ${avgThreshold}s',
        earned: avgSec > 0 && avgSec < avgThreshold,
        progress: avgSec <= 0
            ? 0
            : (avgThreshold / avgSec).clamp(0, 1).toDouble(),
        progressLabel: avgSec <= 0 ? '—' : '${avgSec}s/${avgThreshold}s',
      ),
    );

    return badges;
  }

  IconData _typeIcon(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return Icons.spellcheck;
      case PuzzleType.matching:
        return Icons.compare_arrows;
      case PuzzleType.crossword:
        return Icons.grid_on;
      case PuzzleType.placement:
        return Icons.table_rows;
    }
  }

  String _typeTitleTr(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return 'Kelime Bulmacası';
      case PuzzleType.matching:
        return 'Eşleştirme Oyunu';
      case PuzzleType.crossword:
        return 'Çapraz Bulmaca';
      case PuzzleType.placement:
        return 'Tablo Yerleştirme';
    }
  }

  String _typeTitleEn(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return 'Word Puzzle';
      case PuzzleType.matching:
        return 'Matching Game';
      case PuzzleType.crossword:
        return 'Crossword';
      case PuzzleType.placement:
        return 'Periodic Placement';
    }
  }

  Color _getPuzzleTypeColor(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return AppColors.glowGreen;
      case PuzzleType.matching:
        return AppColors.yellow;
      case PuzzleType.crossword:
        return AppColors.powderRed;
      case PuzzleType.placement:
        return AppColors.turquoise;
    }
  }

  bool _isPremiumBadge(_PuzzleBadge badge, PuzzleType type) {
    final premiumBadgeIndices = _getPremiumBadgeIndices(type);
    final badgeIndex = badge.id.hashCode % 11; // assume 11 badges
    return premiumBadgeIndices.contains(badgeIndex);
  }

  List<int> _getPremiumBadgeIndices(PuzzleType type) {
    switch (type) {
      case PuzzleType.word:
        return [0, 4, 8];
      case PuzzleType.matching:
        return [1, 5, 9];
      case PuzzleType.crossword:
        return [2, 6, 10];
      case PuzzleType.placement:
        return [3, 7, 11];
    }
  }
}

class _PuzzleBadge {
  final String id;
  final IconData icon;
  final String titleTr;
  final String titleEn;
  final String descTr;
  final String descEn;
  final bool earned;
  final double progress; // 0..1
  final String progressLabel;

  _PuzzleBadge({
    required this.id,
    required this.icon,
    required this.titleTr,
    required this.titleEn,
    required this.descTr,
    required this.descEn,
    required this.earned,
    required this.progress,
    required this.progressLabel,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/view/quiz/modern_quiz_home.dart';
import 'package:elements_app/product/widget/premium/premium_overlay.dart';
import 'package:elements_app/product/widget/button/back_button.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView>
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
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
              Icons.emoji_events_outlined,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? 'Başarılar' : 'Achievements',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final provider = context.watch<QuizProvider>();
    final totalEarned = provider.getTotalEarnedBadges();
    final total = provider.getTotalBadgesCount();

    return WillPopScope(
      onWillPop: () async {
        _navigateToQuizHome();
        return false;
      },
      child: AppScaffold(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildModernAppBar(context),
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

              // Main Content with Animations
              SafeArea(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          shrinkWrap: true,
                          children: [
                            _buildModernSummaryCard(isTr, totalEarned, total),
                            const SizedBox(height: 20),
                            _buildModernHint(isTr),
                            const SizedBox(height: 16),
                            ...QuizType.values.map((type) {
                              return _buildModernBadgeStripForType(type, 0);
                            }).toList(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQuizHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ModernQuizHome()),
      (route) => false,
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

  Widget _buildModernSummaryCard(bool isTr, int totalEarned, int total) {
    final progress = total > 0 ? (totalEarned / total) : 0.0;

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
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getPatternPainter(
                  type: PatternType.atomic,
                  color: Colors.white,
                  opacity: 0.05,
                ),
              ),
            ),

            // Decorative Elements
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -15,
              left: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
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
                                  ? 'Kazanılan rozetler: $totalEarned/$total'
                                  : 'Badges earned: $totalEarned/$total',
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

  Widget _buildModernBadgeStripForType(QuizType type, int index) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final provider = context.watch<QuizProvider>();
    final badges = provider.getAchievementsForType(type);
    final colors = _getQuizTypeColors(type);
    final earnedCount = badges.where((b) => b.earned).length;
    final progress = badges.isEmpty ? 0.0 : (earnedCount / badges.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.15),
            colors.primary.withValues(alpha: 0.05),
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
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _patternService.getRandomPatternPainter(
                  seed: type.hashCode,
                  color: Colors.white,
                  opacity: 0.03,
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colors.primary.withValues(alpha: 0.3),
                              colors.primary.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          type.icon,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isTr ? type.turkishTitle : type.englishTitle,
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

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Badges List - Fixed height to prevent overflow
                  SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: badges.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, badgeIndex) {
                        final badge = badges[badgeIndex];
                        final isPremiumBadge = _isPremiumBadge(badge, type);

                        if (isPremiumBadge) {
                          return PremiumOverlay(
                            child: _buildModernBadgeTile(
                              badge,
                              isTr,
                              badgeIndex,
                            ),
                          );
                        } else {
                          return _buildModernBadgeTile(badge, isTr, badgeIndex);
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
                          _navigateToQuizAchievements(type, isTr);
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
                                colors.primary.withValues(alpha: 0.3),
                                colors.primary.withValues(alpha: 0.1),
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

  Widget _buildModernBadgeTile(QuizBadge badge, bool isTr, int index) {
    final earned = badge.earned;
    final provider = context.read<QuizProvider>();
    final stats = provider.getStatisticsForType(badge.type);
    final (double progress, String _) = _computeProgress(badge, stats, isTr);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showModernBadgeDetail(badge, isTr);
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
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and status
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
                                fontSize: 13,
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
                          const SizedBox(width: 8),
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
                              size: 14,
                              color: earned
                                  ? Colors.lightGreenAccent
                                  : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Icon with progress ring
                      Center(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Progress ring
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: earned ? 1 : progress.clamp(0, 1),
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
                                width: 36,
                                height: 36,
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
                                  size: 18,
                                  color: earned
                                      ? Colors.black
                                      : AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Expanded(
                        child: Text(
                          isTr ? badge.descriptionTr : badge.descriptionEn,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
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

  void _navigateToQuizAchievements(QuizType type, bool isTr) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizAchievementsPage(quizType: type),
      ),
    );
  }

  void _showModernBadgeDetail(QuizBadge badge, bool isTr) {
    final provider = context.read<QuizProvider>();
    final stats = provider.getStatisticsForType(badge.type);
    final (double progress, String label) = _computeProgress(
      badge,
      stats,
      isTr,
    );

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
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.steelBlue.withValues(alpha: 0.3),
                blurRadius: 50,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _patternService.getPatternPainter(
                      type: PatternType.atomic,
                      color: Colors.white,
                      opacity: 0.05,
                    ),
                  ),
                ),

                // Decorative Elements
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              badge.icon,
                              color: badge.earned
                                  ? Colors.black
                                  : AppColors.white,
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
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isTr
                                      ? badge.descriptionTr
                                      : badge.descriptionEn,
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
                                  ? Colors.lightGreenAccent.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: badge.earned
                                    ? Colors.lightGreenAccent.withValues(
                                        alpha: 0.3,
                                      )
                                    : Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              badge.earned
                                  ? Icons.check_circle
                                  : Icons.lock_outline,
                              color: badge.earned
                                  ? Colors.lightGreenAccent
                                  : Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Progress Section
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
                                  label,
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
                                value: progress.clamp(0, 1),
                                minHeight: 12,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
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

                      // Earned Date
                      if (badge.earnedAt != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.lightGreenAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.lightGreenAccent.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.lightGreenAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isTr ? 'Kazanım tarihi: ' : 'Earned on: ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${badge.earnedAt!.day}.${badge.earnedAt!.month}.${badge.earnedAt!.year}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  (double, String) _computeProgress(
    QuizBadge badge,
    QuizStatistics stats,
    bool isTr,
  ) {
    final idParts = badge.id.split('_');
    final threshold = int.tryParse(idParts.last) ?? 0;
    final accuracyPct = (stats.accuracy * 100).round();
    final games = stats.totalGamesPlayed;
    final streak = stats.currentStreak;
    final bestScore = stats.bestScore.round();
    final bestTimeSec = stats.bestTime.inSeconds;

    double value = 0;
    String label = '';
    switch (badge.category) {
      case QuizBadgeCategory.games:
        value = threshold == 0 ? 0 : (games / threshold);
        label = '$games/$threshold';
        break;
      case QuizBadgeCategory.accuracy:
        value = threshold == 0 ? 0 : (accuracyPct / threshold);
        label = '%$accuracyPct/%$threshold';
        break;
      case QuizBadgeCategory.streak:
        value = threshold == 0 ? 0 : (streak / threshold);
        label = '$streak/$threshold';
        break;
      case QuizBadgeCategory.mastery:
        value = threshold == 0 ? 0 : (bestScore / threshold);
        label = '%$bestScore/%$threshold';
        break;
      case QuizBadgeCategory.speed:
        if (bestTimeSec <= 0) {
          value = 0;
          label = isTr ? 'Henüz süre yok' : 'No time yet';
        } else {
          value = (threshold / bestTimeSec);
          label = '${bestTimeSec}s/${threshold}s';
        }
        break;
    }
    if (badge.earned) {
      value = 1;
    }
    return (value, label);
  }

  bool _isPremiumBadge(QuizBadge badge, QuizType type) {
    // Her quiz türü için %30'u premium (24 başarımın 8'i)
    final premiumBadgeIndices = _getPremiumBadgeIndices(type);
    final badgeIndex =
        badge.id.hashCode % 24; // 24 başarım olduğunu varsayıyoruz
    return premiumBadgeIndices.contains(badgeIndex);
  }

  List<int> _getPremiumBadgeIndices(QuizType type) {
    // Her quiz türü için farklı premium badge indeksleri
    switch (type) {
      case QuizType.symbol:
        return [0, 3, 6, 9, 12, 15, 18, 21]; // 8/24 = %33.3
      case QuizType.group:
        return [1, 4, 7, 10, 13, 16, 19, 22]; // 8/24 = %33.3
      case QuizType.number:
        return [2, 5, 8, 11, 14, 17, 20, 23]; // 8/24 = %33.3
    }
  }

  ({Color primary, Color shadow}) _getQuizTypeColors(QuizType type) {
    switch (type) {
      case QuizType.symbol:
        return (primary: AppColors.glowGreen, shadow: AppColors.shGlowGreen);
      case QuizType.group:
        return (primary: AppColors.yellow, shadow: AppColors.shYellow);
      case QuizType.number:
        return (primary: AppColors.powderRed, shadow: AppColors.shPowderRed);
    }
  }
}

/// Dedicated page to show all achievements for a specific quiz type
class QuizAchievementsPage extends StatefulWidget {
  final QuizType quizType;

  const QuizAchievementsPage({super.key, required this.quizType});

  @override
  State<QuizAchievementsPage> createState() => _QuizAchievementsPageState();
}

class _QuizAchievementsPageState extends State<QuizAchievementsPage>
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
    final provider = context.watch<QuizProvider>();
    final badges = provider.getAchievementsForType(widget.quizType);
    final colors = _getQuizTypeColors(widget.quizType);
    final earnedCount = badges.where((b) => b.earned).length;
    final progress = badges.isEmpty ? 0.0 : (earnedCount / badges.length);

    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.quiz,
          style: AppBarStyle.gradient,
          title: isTr
              ? '${widget.quizType.turkishTitle} - Başarılar'
              : '${widget.quizType.englishTitle} - Achievements',
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
                        _buildQuizHeader(
                          isTr,
                          earnedCount,
                          badges.length,
                          progress,
                          colors,
                        ),
                        const SizedBox(height: 20),
                        _buildAchievementsGrid(badges, isTr),
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

  Widget _buildQuizHeader(
    bool isTr,
    int earnedCount,
    int totalCount,
    double progress,
    ({Color primary, Color shadow}) colors,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.2),
            colors.primary.withValues(alpha: 0.1),
          ],
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
            color: colors.shadow.withValues(alpha: 0.1),
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
                  seed: widget.quizType.hashCode,
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
                              colors.primary.withValues(alpha: 0.3),
                              colors.primary.withValues(alpha: 0.1),
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
                              color: colors.shadow.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.quizType.icon,
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
                                  ? widget.quizType.turkishTitle
                                  : widget.quizType.englishTitle,
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
                              colors.primary.withValues(alpha: 0.8),
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

  Widget _buildAchievementsGrid(List<QuizBadge> badges, bool isTr) {
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
            final isPremiumBadge = _isPremiumBadge(badge, widget.quizType);

            if (isPremiumBadge) {
              return PremiumOverlay(
                child: _buildGridBadgeTile(badge, isTr, index),
              );
            } else {
              return _buildGridBadgeTile(badge, isTr, index);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGridBadgeTile(QuizBadge badge, bool isTr, int index) {
    final earned = badge.earned;
    final provider = context.read<QuizProvider>();
    final stats = provider.getStatisticsForType(badge.type);
    final (double progress, String _) = _computeProgress(badge, stats, isTr);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showModernBadgeDetail(badge, isTr);
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
                                  value: earned ? 1 : progress.clamp(0, 1),
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
                          isTr ? badge.descriptionTr : badge.descriptionEn,
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

  void _showModernBadgeDetail(QuizBadge badge, bool isTr) {
    final provider = context.read<QuizProvider>();
    final stats = provider.getStatisticsForType(badge.type);
    final (double progress, String label) = _computeProgress(
      badge,
      stats,
      isTr,
    );

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
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: AppColors.steelBlue.withValues(alpha: 0.3),
                blurRadius: 50,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: _patternService.getPatternPainter(
                      type: PatternType.atomic,
                      color: Colors.white,
                      opacity: 0.05,
                    ),
                  ),
                ),

                // Decorative Elements
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              badge.icon,
                              color: badge.earned
                                  ? Colors.black
                                  : AppColors.white,
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
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isTr
                                      ? badge.descriptionTr
                                      : badge.descriptionEn,
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
                                  ? Colors.lightGreenAccent.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: badge.earned
                                    ? Colors.lightGreenAccent.withValues(
                                        alpha: 0.3,
                                      )
                                    : Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              badge.earned
                                  ? Icons.check_circle
                                  : Icons.lock_outline,
                              color: badge.earned
                                  ? Colors.lightGreenAccent
                                  : Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Progress Section
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
                                  label,
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
                                value: progress.clamp(0, 1),
                                minHeight: 12,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.1,
                                ),
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

                      // Earned Date
                      if (badge.earnedAt != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.lightGreenAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.lightGreenAccent.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.lightGreenAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isTr ? 'Kazanım tarihi: ' : 'Earned on: ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${badge.earnedAt!.day}.${badge.earnedAt!.month}.${badge.earnedAt!.year}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  (double, String) _computeProgress(
    QuizBadge badge,
    QuizStatistics stats,
    bool isTr,
  ) {
    final idParts = badge.id.split('_');
    final threshold = int.tryParse(idParts.last) ?? 0;
    final accuracyPct = (stats.accuracy * 100).round();
    final games = stats.totalGamesPlayed;
    final streak = stats.currentStreak;
    final bestScore = stats.bestScore.round();
    final bestTimeSec = stats.bestTime.inSeconds;

    double value = 0;
    String label = '';
    switch (badge.category) {
      case QuizBadgeCategory.games:
        value = threshold == 0 ? 0 : (games / threshold);
        label = '$games/$threshold';
        break;
      case QuizBadgeCategory.accuracy:
        value = threshold == 0 ? 0 : (accuracyPct / threshold);
        label = '%$accuracyPct/%$threshold';
        break;
      case QuizBadgeCategory.streak:
        value = threshold == 0 ? 0 : (streak / threshold);
        label = '$streak/$threshold';
        break;
      case QuizBadgeCategory.mastery:
        value = threshold == 0 ? 0 : (bestScore / threshold);
        label = '%$bestScore/%$threshold';
        break;
      case QuizBadgeCategory.speed:
        if (bestTimeSec <= 0) {
          value = 0;
          label = isTr ? 'Henüz süre yok' : 'No time yet';
        } else {
          value = (threshold / bestTimeSec);
          label = '${bestTimeSec}s/${threshold}s';
        }
        break;
    }
    if (badge.earned) {
      value = 1;
    }
    return (value, label);
  }

  bool _isPremiumBadge(QuizBadge badge, QuizType type) {
    // Her quiz türü için %30'u premium (24 başarımın 8'i)
    final premiumBadgeIndices = _getPremiumBadgeIndices(type);
    final badgeIndex =
        badge.id.hashCode % 24; // 24 başarım olduğunu varsayıyoruz
    return premiumBadgeIndices.contains(badgeIndex);
  }

  List<int> _getPremiumBadgeIndices(QuizType type) {
    // Her quiz türü için farklı premium badge indeksleri
    switch (type) {
      case QuizType.symbol:
        return [0, 3, 6, 9, 12, 15, 18, 21]; // 8/24 = %33.3
      case QuizType.group:
        return [1, 4, 7, 10, 13, 16, 19, 22]; // 8/24 = %33.3
      case QuizType.number:
        return [2, 5, 8, 11, 14, 17, 20, 23]; // 8/24 = %33.3
    }
  }

  ({Color primary, Color shadow}) _getQuizTypeColors(QuizType type) {
    switch (type) {
      case QuizType.symbol:
        return (primary: AppColors.glowGreen, shadow: AppColors.shGlowGreen);
      case QuizType.group:
        return (primary: AppColors.yellow, shadow: AppColors.shYellow);
      case QuizType.number:
        return (primary: AppColors.powderRed, shadow: AppColors.shPowderRed);
    }
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
            ? 'Tüm quiz başarılarınız silinecek. Bu işlem geri alınamaz. Emin misiniz?'
            : 'All your quiz achievements will be deleted. This action cannot be undone. Are you sure?',
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
            context.read<QuizProvider>().clearAchievements();
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

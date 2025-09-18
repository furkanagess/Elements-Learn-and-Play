import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/common/center_quick_actions_row.dart';
import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/feature/view/quiz/unified_quiz_view.dart';
import 'package:elements_app/feature/view/quiz/quiz_statistics_view.dart';
import 'package:elements_app/feature/view/quiz/achievements_view.dart';
import 'package:elements_app/feature/view/home/home_view.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/appBar/app_bars.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/services.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';

/// Modern quiz home view with statistics and quiz selection
class ModernQuizHome extends StatefulWidget {
  const ModernQuizHome({super.key});

  @override
  State<ModernQuizHome> createState() => _ModernQuizHomeState();
}

class _ModernQuizHomeState extends State<ModernQuizHome>
    with TickerProviderStateMixin {
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
  }

  String _localizedDifficulty(String difficulty) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final d = difficulty.toLowerCase();
    if (isTr) {
      if (d == 'easy' || d == 'kolay') return 'Kolay';
      if (d == 'medium' || d == 'orta') return 'Orta';
      if (d == 'hard' || d == 'zor') return 'Zor';
      return difficulty;
    } else {
      if (d == 'easy' || d == 'kolay') return 'Easy';
      if (d == 'medium' || d == 'orta') return 'Medium';
      if (d == 'hard' || d == 'zor') return 'Hard';
      return difficulty;
    }
  }

  // Navigation methods for statistics card
  void _onStatisticsTap() {
    HapticFeedback.lightImpact();
    _navigateToStatistics();
  }

  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizStatisticsView()),
    );
  }

  // Navigation methods for quiz cards
  void _onQuizCardTap(QuizType type) {
    HapticFeedback.lightImpact();
    _startQuiz(type);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBarConfigs.custom(
          theme: AppBarVariant.quiz,
          style: AppBarStyle.gradient,
          title: context.watch<LocalizationProvider>().isTr
              ? 'Quiz Merkezi'
              : 'Quiz Center',
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.white,
              size: 20,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeView()),
                (route) => false,
              );
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

            // Content
            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  CenterQuickActionsRow(
                    statisticsTitle: context.read<LocalizationProvider>().isTr
                        ? 'İstatistikler'
                        : 'Statistics',
                    statisticsSubtitle:
                        context.read<LocalizationProvider>().isTr
                        ? 'Genel görünüm'
                        : 'Overview',
                    statisticsGradient: [
                      AppColors.purple.withValues(alpha: 0.9),
                      AppColors.pink.withValues(alpha: 0.7),
                    ],
                    onStatisticsTap: _onStatisticsTap,
                    achievementsTitle: context.read<LocalizationProvider>().isTr
                        ? 'Başarılar'
                        : 'Achievements',
                    achievementsSubtitle:
                        context.read<LocalizationProvider>().isTr
                        ? 'Rozetler'
                        : 'Badges',
                    achievementsGradient: [
                      AppColors.steelBlue.withValues(alpha: 0.6),
                      AppColors.darkBlue.withValues(alpha: 0.6),
                    ],
                    achievementsFooter: Builder(
                      builder: (ctx) {
                        final provider = ctx.watch<QuizProvider>();
                        final totalEarned = provider.getTotalEarnedBadges();
                        final total = provider.getTotalBadgesCount();
                        return MiniChip(text: '$totalEarned/$total');
                      },
                    ),
                    onAchievementsTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsView(),
                        ),
                      );
                    },
                  ),
                  _modernCenterSeparator(context),
                  _buildQuizTypesSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Row(
      children: [
        Expanded(
          child: _squareAction(
            title: isTr ? 'İstatistikler' : 'Statistics',
            subtitle: isTr ? 'Genel görünüm' : 'Overview',
            icon: Icons.analytics_rounded,
            gradientColors: [
              AppColors.purple.withValues(alpha: 0.9),
              AppColors.pink.withValues(alpha: 0.7),
            ],
            onTap: _onStatisticsTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _squareAction(
            title: isTr ? 'Başarılar' : 'Achievements',
            subtitle: isTr ? 'Rozetler' : 'Badges',
            icon: Icons.emoji_events_rounded,
            gradientColors: [
              AppColors.steelBlue.withValues(alpha: 0.6),
              AppColors.darkBlue.withValues(alpha: 0.6),
            ],
            footerBuilder: (ctx) {
              final provider = ctx.watch<QuizProvider>();
              final totalEarned = provider.getTotalEarnedBadges();
              final total = provider.getTotalBadgesCount();
              return _miniChip(text: '$totalEarned/$total');
            },
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsView(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _squareAction({
    required String title,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    String? subtitle,
    Widget Function(BuildContext context)? footerBuilder,
  }) {
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
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
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
                      painter: _patternService.getPatternPainter(
                        type: PatternType.molecular,
                        color: Colors.white,
                        opacity: 0.05,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    right: -12,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -10,
                    left: -10,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
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
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
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
                              color: Colors.white.withValues(alpha: 0.85),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BannerAdsWidget(showLoadingIndicator: true),
        const SizedBox(height: 8),
        Padding(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
                  context.read<LocalizationProvider>().isTr
                      ? 'Oyunlar'
                      : 'Games',
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
        ),
      ],
    );
  }

  Widget _miniChip({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1,
        ),
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

  // (old full-width cards removed)

  Widget _buildQuizTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...QuizType.values.map((type) => _buildQuizTypeCard(type)).toList(),
      ],
    );
  }

  Widget _buildQuizTypeCard(QuizType type) {
    final colors = _getQuizTypeColors(type);
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onQuizCardTap(type),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.3),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: 2,
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
                      opacity: 0.08,
                    ),
                  ),
                ),

                // Decorative Elements
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
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
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
                          type.icon,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isTr ? type.turkishTitle : type.englishTitle,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                              _getQuizDescriptionLocalized(type, isTr),
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.25,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _localizedDifficulty(type.difficulty),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Consumer<QuizProvider>(
                                  builder: (context, provider, child) {
                                    final stats = provider.getStatisticsForType(
                                      type,
                                    );
                                    return Text(
                                      isTr
                                          ? 'En İyi: %${stats.bestScore.toInt()}'
                                          : 'Best: %${stats.bestScore.toInt()}',
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startQuiz(QuizType type) {
    context.read<AdmobProvider>().onRouteChanged();

    // Show loading screen
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildLoadingDialog();
      },
    );

    // Simulate loading time and then navigate
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnifiedQuizView(quizType: type),
          ),
        );
      }
    });
  }

  ({Color primary, Color shadow}) _getQuizTypeColors(QuizType type) {
    switch (type) {
      case QuizType.symbol:
        return (primary: AppColors.turquoise, shadow: AppColors.shTurquoise);
      case QuizType.group:
        return (primary: AppColors.steelBlue, shadow: AppColors.shSteelBlue);
      case QuizType.number:
        return (primary: AppColors.purple, shadow: AppColors.shPurple);
    }
  }

  String _getQuizDescriptionLocalized(QuizType type, bool isTr) {
    switch (type) {
      case QuizType.symbol:
        return isTr
            ? 'Sembol verildiğinde element adını bulun'
            : 'Find the element name given its symbol';
      case QuizType.group:
        return isTr
            ? 'Element adı verildiğinde grubunu bulun'
            : 'Find the group given the element name';
      case QuizType.number:
        return isTr
            ? 'Atom numarası verildiğinde element adını bulun'
            : 'Find the element name given the atomic number';
    }
  }

  Widget _buildLoadingDialog() {
    final isTr = context.read<LocalizationProvider>().isTr;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBlue.withValues(alpha: 0.95),
              AppColors.steelBlue.withValues(alpha: 0.9),
              AppColors.purple.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
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
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _patternService.getPatternPainter(
                    type: PatternType.atomic,
                    color: Colors.white,
                    opacity: 0.05,
                  ),
                ),
              ),
              // Decorative elements
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 40,
                  height: 40,
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
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loading icon
                  Container(
                    width: 80,
                    height: 80,
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
                      Icons.quiz_rounded,
                      color: AppColors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Loading text
                  Text(
                    isTr ? 'Testler Yükleniyor' : 'Loading Tests',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Loading indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

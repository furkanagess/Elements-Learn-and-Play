import 'package:elements_app/product/widget/button/back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elements_app/product/constants/assets_constants.dart';
import 'package:elements_app/product/widget/ads/banner_ads_widget.dart';

class QuizStatisticsView extends StatefulWidget {
  const QuizStatisticsView({super.key});

  @override
  State<QuizStatisticsView> createState() => _QuizStatisticsViewState();
}

class _QuizStatisticsViewState extends State<QuizStatisticsView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Pattern service for background patterns
  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

            // Main Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Consumer<QuizProvider>(
                  builder: (context, provider, child) {
                    final totalGames = provider.getTotalGamesPlayed();
                    final averageAccuracy = provider.getAverageAccuracy();
                    final totalStreak = provider.getTotalStreak();
                    final bestScore = provider.getBestScore();
                    final hasNoData =
                        totalGames == 0 &&
                        averageAccuracy == 0 &&
                        totalStreak == 0 &&
                        bestScore == 0;

                    if (hasNoData) {
                      // Show empty state centered on screen
                      return Center(child: _buildOverallStats(provider));
                    } else {
                      // Show normal statistics with detailed cards
                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Genel İstatistikler
                          SliverToBoxAdapter(
                            child: _buildOverallStats(provider),
                          ),

                          // Banner Ad
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            sliver: SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.darkBlue.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: const BannerAdsWidget(),
                                ),
                              ),
                            ),
                          ),

                          // Quiz Türlerine Göre İstatistikler
                          SliverPadding(
                            padding: const EdgeInsets.all(20),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                ...QuizType.values
                                    .map(
                                      (type) => _buildDetailedStatCard(
                                        type,
                                        provider,
                                      ),
                                    )
                                    .toList(),
                              ]),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.glowGreen,
              AppColors.yellow.withValues(alpha: 0.95),
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
            child: SvgPicture.asset(
              AssetConstants.instance.svgQuestionTwo,
              colorFilter: const ColorFilter.mode(
                AppColors.white,
                BlendMode.srcIn,
              ),
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.read<LocalizationProvider>().isTr
                ? 'Quiz İstatistikleri'
                : 'Quiz Statistics',
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
            onPressed: () => _showClearStatsDialog(context),
          ),
        ),
      ],
      elevation: 0,
    );
  }

  Widget _buildOverallStats(QuizProvider provider) {
    final totalGames = provider.getTotalGamesPlayed();
    final averageAccuracy = provider.getAverageAccuracy();
    final totalStreak = provider.getTotalStreak();
    final bestScore = provider.getBestScore();

    // Check if all values are zero (no quiz played yet)
    final hasNoData =
        totalGames == 0 &&
        averageAccuracy == 0 &&
        totalStreak == 0 &&
        bestScore == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: hasNoData
          ? Center(child: _buildEmptyState())
          : _buildStatsContent(
              totalGames,
              averageAccuracy,
              totalStreak,
              bestScore,
            ),
    );
  }

  Widget _buildEmptyState() {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.extension_rounded,
            color: AppColors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          isTr ? 'Henüz Quiz Oynamadınız' : 'No Quizzes Played Yet',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isTr
              ? 'İstatistikleri görmek için quiz oynayın!'
              : 'Play quizzes to see your statistics!',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsContent(
    int totalGames,
    double averageAccuracy,
    int totalStreak,
    double bestScore,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              context.read<LocalizationProvider>().isTr
                  ? 'Genel Performans'
                  : 'Overall Performance',
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
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildOverallStatItem(
                context.read<LocalizationProvider>().isTr
                    ? 'Toplam Quiz'
                    : 'Total Quizzes',
                totalGames.toString(),
                Icons.quiz_rounded,
              ),
            ),
            Expanded(
              child: _buildOverallStatItem(
                context.read<LocalizationProvider>().isTr
                    ? 'Ortalama'
                    : 'Average',
                '%${(averageAccuracy * 100).toInt()}',
                Icons.analytics_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOverallStatItem(
                context.read<LocalizationProvider>().isTr
                    ? 'Toplam Seri'
                    : 'Total Streak',
                totalStreak.toString(),
                Icons.local_fire_department_rounded,
              ),
            ),
            Expanded(
              child: _buildOverallStatItem(
                context.read<LocalizationProvider>().isTr
                    ? 'En İyi Skor'
                    : 'Best Score',
                '%${bestScore.toInt()}',
                Icons.emoji_events_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverallStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
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
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatCard(QuizType type, QuizProvider provider) {
    final stats = provider.getStatisticsForType(type);
    final colors = _getQuizTypeColors(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.9),
            colors.primary.withValues(alpha: 0.7),
            colors.primary.withValues(alpha: 0.5),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
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
                  seed: type.index,
                  color: Colors.white,
                  opacity: 0.1,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(type.icon, color: AppColors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.read<LocalizationProvider>().isTr
                                ? type.turkishTitle
                                : type.englishTitle,
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
                          const SizedBox(height: 2),
                          Text(
                            _getQuizDescription(type),
                            style: TextStyle(
                              color: AppColors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailedStatItem(
                      context.read<LocalizationProvider>().isTr
                          ? 'Oyun'
                          : 'Games',
                      stats.totalGamesPlayed.toString(),
                    ),
                    _buildDetailedStatItem(
                      context.read<LocalizationProvider>().isTr
                          ? 'Doğruluk'
                          : 'Accuracy',
                      '%${(stats.accuracy * 100).toInt()}',
                    ),
                    _buildDetailedStatItem(
                      context.read<LocalizationProvider>().isTr
                          ? 'Seri'
                          : 'Streak',
                      stats.currentStreak.toString(),
                    ),
                    _buildDetailedStatItem(
                      context.read<LocalizationProvider>().isTr
                          ? 'Rekor'
                          : 'Record',
                      stats.longestStreak.toString(),
                    ),
                  ],
                ),
                if (stats.totalGamesPlayed > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: stats.accuracy,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary.withValues(alpha: 0.8),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStatItem(String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
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
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showClearStatsDialog(BuildContext context) {
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
              context.read<LocalizationProvider>().isTr
                  ? 'İstatistikleri Temizle'
                  : 'Clear Statistics',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          context.read<LocalizationProvider>().isTr
              ? 'Tüm quiz istatistikleriniz silinecek. Bu işlem geri alınamaz. Emin misiniz?'
              : 'All your quiz statistics will be deleted. This action cannot be undone. Are you sure?',
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
              context.read<LocalizationProvider>().isTr ? 'İptal' : 'Cancel',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<QuizProvider>().clearStatistics();
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
              context.read<LocalizationProvider>().isTr ? 'Temizle' : 'Clear',
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

  String _getQuizDescription(QuizType type) {
    final isTr = context.read<LocalizationProvider>().isTr;
    switch (type) {
      case QuizType.symbol:
        return isTr
            ? 'Sembol verildiğinde element adını bulun'
            : 'Find element name when symbol is given';
      case QuizType.group:
        return isTr
            ? 'Element adı verildiğinde grubunu bulun'
            : 'Find group when element name is given';
      case QuizType.number:
        return isTr
            ? 'Atom numarası verildiğinde element adını bulun'
            : 'Find element name when atomic number is given';
    }
  }
}

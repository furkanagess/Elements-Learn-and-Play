import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/provider/trivia_provider.dart';
import 'package:elements_app/product/widget/premium/premium_overlay.dart';
import 'package:elements_app/product/widget/button/back_button.dart';

class TriviaStatisticsView extends StatefulWidget {
  const TriviaStatisticsView({super.key});

  @override
  State<TriviaStatisticsView> createState() => _TriviaStatisticsViewState();
}

class _TriviaStatisticsViewState extends State<TriviaStatisticsView>
    with TickerProviderStateMixin {
  final PatternService _pattern = PatternService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
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
    final isTr = context.watch<LocalizationProvider>().isTr;
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
        appBar: _buildAppBar(isTr),
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
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Consumer<TriviaProvider>(
                  builder: (context, provider, child) {
                    final totalPlays = provider.totalGamesPlayed;
                    final totalWins = provider.totalWins;
                    final winRate = provider.winRate;
                    final bestTime = provider.bestTime;

                    final hasNoData = totalPlays == 0;
                    if (hasNoData) {
                      return Center(child: _buildEmptyState(isTr));
                    }

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        _overallCard(
                          context,
                          totalPlays: totalPlays,
                          totalWins: totalWins,
                          winRate: winRate,
                          bestTime: bestTime,
                          totalCorrect: provider.totalCorrectAnswers,
                          totalWrong: provider.totalWrongAnswers,
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _perCategoryHeader(isTr),
                            const SizedBox(height: 12),

                            // Premium Categories (%30 - 2/7)
                            PremiumOverlay(
                              title: isTr
                                  ? 'Sınıflandırma İstatistikleri'
                                  : 'Classification Statistics',
                              description: isTr
                                  ? 'Premium ile sınıflandırma kategorisinin detaylı performansını görün'
                                  : 'View detailed performance for classification category with Premium',
                              child: _categoryRow(
                                context,
                                isTr: isTr,
                                labelTr: 'Sınıflandırma',
                                labelEn: 'Classification',
                                stats: provider.getCategoryStats(
                                  TriviaCategory.classification,
                                ),
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 10),
                            PremiumOverlay(
                              title: isTr
                                  ? 'Atom Ağırlığı İstatistikleri'
                                  : 'Atomic Weight Statistics',
                              description: isTr
                                  ? 'Premium ile atom ağırlığı kategorisinin detaylı performansını görün'
                                  : 'View detailed performance for atomic weight category with Premium',
                              child: _categoryRow(
                                context,
                                isTr: isTr,
                                labelTr: 'Atom Ağırlığı',
                                labelEn: 'Atomic Weight',
                                stats: provider.getCategoryStats(
                                  TriviaCategory.weight,
                                ),
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Free Categories (%70 - 5/7)
                            _categoryRow(
                              context,
                              isTr: isTr,
                              labelTr: 'Periyot',
                              labelEn: 'Period',
                              stats: provider.getCategoryStats(
                                TriviaCategory.period,
                              ),
                              color: Colors.pinkAccent,
                            ),
                            const SizedBox(height: 10),
                            _categoryRow(
                              context,
                              isTr: isTr,
                              labelTr: 'Açıklama',
                              labelEn: 'Description',
                              stats: provider.getCategoryStats(
                                TriviaCategory.description,
                              ),
                              color: Colors.cyan,
                            ),
                            const SizedBox(height: 10),
                            _categoryRow(
                              context,
                              isTr: isTr,
                              labelTr: 'Kullanım',
                              labelEn: 'Uses',
                              stats: provider.getCategoryStats(
                                TriviaCategory.usage,
                              ),
                              color: Colors.lightGreen,
                            ),
                            const SizedBox(height: 10),
                            _categoryRow(
                              context,
                              isTr: isTr,
                              labelTr: 'Kaynak',
                              labelEn: 'Source',
                              stats: provider.getCategoryStats(
                                TriviaCategory.source,
                              ),
                              color: Colors.deepOrangeAccent,
                            ),
                            const SizedBox(height: 10),
                            _categoryRow(
                              context,
                              isTr: isTr,
                              labelTr: 'Karışık',
                              labelEn: 'Mixed',
                              stats: provider.getCategoryStats(
                                TriviaCategory.mixed,
                              ),
                              color: Colors.deepPurpleAccent,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTr) {
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
          isTr ? 'Henüz Trivia Oynamadınız' : 'No Trivia Played Yet',
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
              ? 'İstatistikleri görmek için trivia oynayın!'
              : 'Play trivia to see your statistics!',
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

  PreferredSizeWidget _buildAppBar(bool isTr) {
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
              Icons.analytics_outlined,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? 'Trivia İstatistikleri' : 'Trivia Statistics',
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

  Widget _overallCard(
    BuildContext context, {
    required int totalPlays,
    required int totalWins,
    required double winRate,
    required Duration bestTime,
    required int totalCorrect,
    required int totalWrong,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Container(
      decoration: BoxDecoration(
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
        borderRadius: BorderRadius.circular(24),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _statBox(
                label: isTr ? 'Toplam Oyun' : 'Total Plays',
                value: '$totalPlays',
              ),
              const SizedBox(width: 12),
              _statBox(label: isTr ? 'Kazanma' : 'Wins', value: '$totalWins'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBox(
                label: isTr ? 'Doğru' : 'Correct',
                value: '$totalCorrect',
              ),
              const SizedBox(width: 12),
              _statBox(label: isTr ? 'Yanlış' : 'Wrong', value: '$totalWrong'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statBox(
                label: isTr ? 'Kazanma Oranı' : 'Win Rate',
                value: '%${(winRate * 100).toInt()}',
              ),
              const SizedBox(width: 12),
              _statBox(
                label: isTr ? 'En İyi Süre' : 'Best Time',
                value: bestTime == Duration.zero ? '—' : _format(bestTime),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showClearStatsDialog(BuildContext context) {
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
              isTr ? 'İstatistikleri Temizle' : 'Clear Statistics',
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
              ? 'Tüm trivia istatistikleriniz silinecek. Bu işlem geri alınamaz. Emin misiniz?'
              : 'All your trivia statistics will be deleted. This action cannot be undone. Are you sure?',
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

  Widget _perCategoryHeader(bool isTr) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: const Icon(Icons.category, color: AppColors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          isTr ? 'Kategorilere Göre' : 'By Category',
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _categoryRow(
    BuildContext context, {
    required bool isTr,
    required String labelTr,
    required String labelEn,
    required TriviaCategoryStats stats,
    required Color color,
  }) {
    final label = isTr ? labelTr : labelEn;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Icon(
              Icons.analytics,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _miniStat(
                      isTr ? 'Oyun' : 'Plays',
                      '${stats.totalGamesPlayed}',
                    ),
                    const SizedBox(width: 8),
                    _miniStat(isTr ? 'Kazanma' : 'Wins', '${stats.totalWins}'),
                    const SizedBox(width: 8),
                    _miniStat(
                      isTr ? 'Oran' : 'Rate',
                      '%${(stats.winRate * 100).toInt()}',
                    ),
                    const SizedBox(width: 8),
                    _miniStat(
                      isTr ? 'En İyi' : 'Best',
                      stats.bestTime == Duration.zero
                          ? '—'
                          : _format(stats.bestTime),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

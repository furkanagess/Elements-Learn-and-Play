import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/provider/puzzle_provider.dart';
import 'package:elements_app/feature/model/puzzle/puzzle_models.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:flutter/services.dart';
import 'package:elements_app/product/widget/premium/premium_overlay.dart';

class PuzzlesStatisticsView extends StatefulWidget {
  const PuzzlesStatisticsView({super.key});

  @override
  State<PuzzlesStatisticsView> createState() => _PuzzlesStatisticsViewState();
}

class _PuzzlesStatisticsViewState extends State<PuzzlesStatisticsView>
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
        backgroundColor: AppColors.background,
        appBar: _buildModernAppBar(isTr),
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
                child: Consumer<PuzzleProvider>(
                  builder: (context, provider, child) {
                    final word = provider.getProgress(PuzzleType.word);
                    final matching = provider.getProgress(PuzzleType.matching);

                    final totalPlays = word.totalPlays + matching.totalPlays;
                    final totalWins = word.totalWins + matching.totalWins;
                    final winRate = totalPlays == 0
                        ? 0.0
                        : (totalWins / totalPlays.toDouble());
                    final bestTime = _minNonZero(
                      word.bestTime,
                      matching.bestTime,
                    );

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
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            // Premium: Word Puzzle (%30 - 1/2)
                            PremiumOverlay(
                              title: isTr
                                  ? 'Kelime Bulmacası İstatistikleri'
                                  : 'Word Puzzle Statistics',
                              description: isTr
                                  ? 'Premium ile kelime bulmacasının detaylı performansını görün'
                                  : 'View detailed performance for word puzzle with Premium',
                              child: _perTypeCard(
                                context,
                                title: isTr
                                    ? 'Kelime Bulmacası'
                                    : 'Word Puzzle',
                                progress: word,
                                color: AppColors.glowGreen,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Free: Matching Game (%70 - 1/2)
                            _perTypeCard(
                              context,
                              title: isTr
                                  ? 'Eşleştirme Oyunu'
                                  : 'Matching Game',
                              progress: matching,
                              color: AppColors.yellow,
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

  PreferredSizeWidget _buildModernAppBar(bool isTr) {
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
      title: Text(
        isTr ? 'Bulmaca İstatistikleri' : 'Puzzle Statistics',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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

  Duration _minNonZero(Duration a, Duration b) {
    if (a == Duration.zero) return b;
    if (b == Duration.zero) return a;
    return a < b ? a : b;
  }

  Widget _overallCard(
    BuildContext context, {
    required int totalPlays,
    required int totalWins,
    required double winRate,
    required Duration bestTime,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBox(
                label: isTr ? 'Toplam Oyun' : 'Total Plays',
                value: totalPlays.toString(),
              ),
              const SizedBox(width: 12),
              _statBox(
                label: isTr ? 'Toplam Kazanma' : 'Total Wins',
                value: totalWins.toString(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statBox(
                label: isTr ? 'Kazanma Oranı' : 'Win Rate',
                value: '%${(winRate * 100).toInt()}',
              ),
              const SizedBox(width: 12),
              _statBox(
                label: isTr ? 'En İyi Süre' : 'Best Time',
                value: bestTime == Duration.zero
                    ? (isTr ? '—' : '—')
                    : _formatDuration(bestTime),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _perTypeCard(
    BuildContext context, {
    required String title,
    required PuzzleProgress progress,
    required Color color,
  }) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final winRate = progress.totalPlays == 0
        ? 0.0
        : progress.totalWins / progress.totalPlays.toDouble();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _smallStat(
                label: isTr ? 'Oyun' : 'Plays',
                value: progress.totalPlays.toString(),
              ),
              const SizedBox(width: 8),
              _smallStat(
                label: isTr ? 'Kazanma' : 'Wins',
                value: progress.totalWins.toString(),
              ),
              const SizedBox(width: 8),
              _smallStat(
                label: isTr ? 'Oran' : 'Rate',
                value: '%${(winRate * 100).toInt()}',
              ),
              const SizedBox(width: 8),
              _smallStat(
                label: isTr ? 'En İyi' : 'Best',
                value: progress.bestTime == Duration.zero
                    ? (isTr ? '—' : '—')
                    : _formatDuration(progress.bestTime),
              ),
            ],
          ),
        ],
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
          isTr ? 'Henüz Bulmaca Oynamadınız' : 'No Puzzles Played Yet',
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
              ? 'İstatistikleri görmek için bulmaca oynayın!'
              : 'Play puzzles to see your statistics!',
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

  Widget _statBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
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
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallStat({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
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
              child: Icon(
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
              ? 'Tüm bulmaca istatistikleriniz silinecek. Bu işlem geri alınamaz. Emin misiniz?'
              : 'All your puzzle statistics will be deleted. This action cannot be undone. Are you sure?',
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

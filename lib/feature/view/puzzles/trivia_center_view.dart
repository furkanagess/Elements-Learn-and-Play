import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
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
              Icons.quiz_outlined,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? 'Trivia Merkezi' : 'Trivia Center',
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
    return _ModernTriviaCard(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
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
}

/// Modern trivia card widget with animations and modern UI
class _ModernTriviaCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModernTriviaCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ModernTriviaCard> createState() => _ModernTriviaCardState();
}

class _ModernTriviaCardState extends State<_ModernTriviaCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.1,
                ), // Opacity white background
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.2,
                  ), // Opacity white border
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon Container (similar to tests home view)
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(
                          alpha: 0.6,
                        ), // Card color
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.color.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),

                    // Content (similar to tests home view)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
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
                            widget.subtitle,
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
                              _buildChip('Category'),
                              const SizedBox(width: 8),
                              _buildChip('Trivia'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Start Button (similar to tests home view)
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
                      child: const Text(
                        'Start',
                        style: TextStyle(
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
        },
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
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

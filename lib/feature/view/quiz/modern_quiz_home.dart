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
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/button/back_button.dart';
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
            child: const Icon(Icons.quiz, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            isTr ? 'Quiz Merkezi' : 'Quiz Center',
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
  void _onQuizCardTap(QuizType type, {bool first20Only = false}) {
    HapticFeedback.lightImpact();
    final globalFirst20 = context.read<QuizProvider>().useFirst20Elements;
    _startQuiz(type, first20Only: first20Only || globalFirst20);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
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

    return _ModernQuizCard(
      type: type,
      colors: colors,
      isTr: isTr,
      onTap: () => _onQuizCardTap(type),
      onLongPress: () => _onQuizCardTap(type, first20Only: true),
    );
  }

  void _startQuiz(QuizType type, {bool first20Only = false}) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Track route change for ads
    context.read<AdmobProvider>().onRouteChanged();

    // Direct navigation with context.mounted check
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UnifiedQuizView(quizType: type, first20Only: first20Only),
        ),
      );
    }
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
}

/// Modern quiz card widget with animations and modern UI
class _ModernQuizCard extends StatefulWidget {
  final QuizType type;
  final ({Color primary, Color shadow}) colors;
  final bool isTr;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ModernQuizCard({
    required this.type,
    required this.colors,
    required this.isTr,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ModernQuizCard> createState() => _ModernQuizCardState();
}

class _ModernQuizCardState extends State<_ModernQuizCard>
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

  void _onLongPress() {
    widget.onLongPress();
  }

  void _handleTap() {
    widget.onTap();
  }

  /// Build card decoration (similar to other modern cards)
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: widget.colors.primary.withValues(
        alpha: 0.15,
      ), // Element color background
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: widget.colors.primary.withValues(
          alpha: 0.4,
        ), // Element color border
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: widget.colors.primary.withValues(
            alpha: 0.3,
          ), // Element color shadow
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Build quiz icon container (similar to tests home view)
  Widget _buildQuizIconContainer() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: widget.colors.primary.withValues(alpha: 0.6), // Card color
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.colors.primary.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.colors.shadow.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(widget.type.icon, color: Colors.white, size: 28),
    );
  }

  /// Build difficulty chip
  Widget _buildDifficultyChip() {
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
        _localizedDifficulty(widget.type.difficulty),
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build stats chip (similar to tests home view)
  Widget _buildStatsChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
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

  /// Build start button (similar to tests home view)
  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Text(
        widget.isTr ? 'Başla' : 'Start',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _scaleController.forward(),
            onTapUp: (_) => _handleTap(),
            onTapCancel: () => _scaleController.reverse(),
            onLongPress: _onLongPress,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: _buildCardDecoration(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Quiz Icon Container (similar to tests home view)
                    _buildQuizIconContainer(),
                    const SizedBox(width: 14),

                    // Quiz Info (similar to tests home view)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quiz Title
                          Text(
                            widget.isTr
                                ? widget.type.turkishTitle
                                : widget.type.englishTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Quiz Description
                          Text(
                            _getQuizDescriptionLocalized(
                              widget.type,
                              widget.isTr,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Difficulty and Stats Row
                          Row(
                            children: [
                              _buildDifficultyChip(),
                              const SizedBox(width: 8),
                              Consumer<QuizProvider>(
                                builder: (context, provider, child) {
                                  final stats = provider.getStatisticsForType(
                                    widget.type,
                                  );
                                  return _buildStatsChip(
                                    widget.isTr
                                        ? 'En İyi: %${stats.bestScore.toInt()}'
                                        : 'Best: %${stats.bestScore.toInt()}',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Start Button (similar to tests home view)
                    _buildStartButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _localizedDifficulty(String difficulty) {
    final d = difficulty.toLowerCase();
    if (widget.isTr) {
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
}

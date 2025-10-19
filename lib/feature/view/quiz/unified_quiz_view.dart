import 'package:elements_app/feature/view/tests/tests_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/quiz/quiz_components.dart';
import 'package:elements_app/product/widget/skeleton/universal_skeleton_loader.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/product/ads/rewarded_helper.dart';
import 'package:elements_app/feature/view/quiz/achievements_view.dart';

/// Unified quiz view that handles all quiz types with modern UI
class UnifiedQuizView extends StatefulWidget {
  final QuizType quizType;
  final bool first20Only;

  const UnifiedQuizView({
    super.key,
    required this.quizType,
    this.first20Only = false,
  });

  @override
  State<UnifiedQuizView> createState() => _UnifiedQuizViewState();
}

class _UnifiedQuizViewState extends State<UnifiedQuizView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _hasShownResultDialog = false;

  final PatternService _patternService = PatternService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startQuiz();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  void _startQuiz() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasShownResultDialog = false;
      context.read<QuizProvider>().startQuiz(
        widget.quizType,
        first20Only: widget.first20Only,
        context: context,
      );
    });
  }

  void _startNewQuiz() {
    // Reset the quiz provider completely and start fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = context.read<QuizProvider>();
      quizProvider.resetQuiz();
      // Start a completely new quiz session
      quizProvider.startQuiz(
        widget.quizType,
        first20Only: widget.first20Only,
        context: context,
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          final session = quizProvider.currentSession;

          if (session == null || quizProvider.isLoading) {
            return _buildLoadingState();
          }

          if (session.state == QuizState.error) {
            return _buildErrorState(session.errorMessage ?? 'Bilinmeyen hata');
          }

          return _buildQuizState(context, quizProvider, session);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const UniversalSkeletonLoader(
      type: SkeletonType.quiz,
      showAppBar: false,
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    return Container(
      color: AppColors.background,
      child: Stack(
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    maxHeight: 600,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: AppColors.powderRed,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isTr ? 'Quiz Yüklenemedi' : 'Failed to Load Quiz',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        errorMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.white.withValues(alpha: 0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isTr ? 'Geri Dön' : 'Go Back',
                                style: const TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _startQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.purple,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                isTr ? 'Tekrar Dene' : 'Retry',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizState(
    BuildContext context,
    QuizProvider quizProvider,
    QuizSession session,
  ) {
    // Show result dialog when state indicates completion or failure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🔍 Checking quiz completion...');
      debugPrint('🔍 Session state: ${session.state}');
      debugPrint('🔍 Current question index: ${session.currentQuestionIndex}');
      debugPrint('🔍 Total questions: ${session.questions.length}');
      debugPrint('🔍 Correct answers: ${session.correctAnswers}');
      debugPrint('🔍 Wrong answers: ${session.wrongAnswers}');

      final bool shouldShowResult =
          session.state == QuizState.completed ||
          session.state == QuizState.failed;

      if (shouldShowResult && !_hasShownResultDialog) {
        debugPrint('✅ Quiz ended! Showing dialog...');
        debugPrint(
          '🎯 Quiz result: ${session.state == QuizState.completed ? "SUCCESS" : "FAILED"}',
        );
        _hasShownResultDialog = true;
        // Add a small delay to ensure UI is ready
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            _showResultDialog(context, quizProvider, session);
          }
        });
      }
    });

    return Container(
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _patternService.getPatternPainter(
                type: PatternType.atomic,
                color: Colors.white,
                opacity: 0.02,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Modern Quiz Header - Similar to Puzzle Header
                  Container(
                    height: MediaQuery.of(context).size.height * 0.16,
                    child: _ModernQuizHeader(
                      session: session,
                      onClose: () => _handleQuizExit(context, quizProvider),
                    ),
                  ),

                  // Main quiz content - Similar to puzzle content
                  Expanded(
                    child: _ModernQuizContent(
                      session: session,
                      quizProvider: quizProvider,
                      fadeAnimation: _fadeAnimation,
                      slideAnimation: _slideAnimation,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(
    BuildContext context,
    QuizProvider quizProvider,
    QuizSession session,
  ) {
    debugPrint('🎯 Showing result dialog for session: ${session.id}');
    debugPrint('🎯 Session state: ${session.state}');
    debugPrint('🎯 Session isCompleted: ${session.isCompleted}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizResultDialog(
        session: session,
        onRestart: () async {
          await _maybeShowAchievementsCongrats(quizProvider, session.type);
          // Prepare for a clean restart
          _hasShownResultDialog = false;
          quizProvider.resetQuiz();
          _startNewQuiz();
        },
        onHome: () async {
          // Show achievements before navigating home
          await _maybeShowAchievementsCongrats(quizProvider, session.type);
          // Prevent dialog from reopening before navigation completes
          _hasShownResultDialog = false;
          _navigateToHome(context, quizProvider);
        },
        onWatchAdForExtraLife: () async {
          Navigator.of(context).pop();
          final rewardEarned = await RewardedHelper.showRewardedAd(
            context: context,
          );
          if (rewardEarned && mounted) {
            quizProvider.continueAfterReward();
            _hasShownResultDialog = false;
          } else if (mounted) {
            // Ad failed or user didn't earn reward, show failure dialog again
            _showResultDialog(context, quizProvider, session);
          }
        },
      ),
    );
  }

  Future<void> _maybeShowAchievementsCongrats(
    QuizProvider provider,
    QuizType type,
  ) async {
    final newlyEarned = provider.consumeLastEarnedBadges();
    if (newlyEarned.isEmpty) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _AchievementCongratsDialog(
        badges: newlyEarned,
        type: type,
        onHome: () => _navigateToHome(context, provider),
      ),
    );
  }

  void _handleQuizExit(BuildContext context, QuizProvider quizProvider) {
    final isTr = context.read<LocalizationProvider>().isTr;
    if (quizProvider.hasActiveSession) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isTr ? 'Quiz\'den Çık' : 'Exit Quiz',
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            isTr
                ? 'Quiz\'i şimdi bırakırsanız ilerlemeniz kaybolacak. Emin misiniz?'
                : 'If you exit now, your progress will be lost. Are you sure?',
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isTr ? 'İptal' : 'Cancel',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _navigateToHome(context, quizProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.powderRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isTr ? 'Çık' : 'Exit',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      _navigateToHome(context, quizProvider);
    }
  }

  void _navigateToHome(BuildContext context, QuizProvider quizProvider) {
    context.read<AdmobProvider>().onRouteChanged(context: context);
    quizProvider.resetQuiz();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => TestsHomeView()),
      (route) => false,
    );
  }
}

class _AchievementCongratsDialog extends StatelessWidget {
  final List<QuizBadge> badges;
  final QuizType type;
  final VoidCallback? onHome;

  const _AchievementCongratsDialog({
    required this.badges,
    required this.type,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final colors = _getTypeColors(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.1),
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
              color: colors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTr
                        ? 'Tebrikler! Yeni başarımlar kazandın'
                        : 'Congrats! You earned new achievements',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...badges.take(3).map((b) => _buildBadgeRow(b, isTr)).toList(),
            if (badges.length > 3) ...[
              const SizedBox(height: 8),
              Text(
                isTr
                    ? '+${badges.length - 3} diğer başarı'
                    : '+${badges.length - 3} more',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
            const SizedBox(height: 20),
            // First row: Awesome and View Achievements
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isTr ? 'Harika!' : 'Awesome!',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AchievementsView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isTr ? 'Başarıları Gör' : 'View Achievements',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Second row: Home button (if onHome callback is provided)
            if (onHome != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onHome!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.powderRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isTr ? 'Ana Sayfa' : 'Home',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(QuizBadge b, bool isTr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(b.icon, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTr ? b.titleTr : b.titleEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isTr ? b.descriptionTr : b.descriptionEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ({Color primary, Color shadow}) _getTypeColors(QuizType type) {
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

/// Modern quiz header similar to Puzzle Header
class _ModernQuizHeader extends StatelessWidget {
  final QuizSession session;
  final VoidCallback? onClose;

  const _ModernQuizHeader({required this.session, this.onClose});

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row with close button, title and difficulty
            Row(
              children: [
                if (onClose != null)
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTr
                        ? session.type.turkishTitle
                        : session.type.englishTitle,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(session.type.icon, color: AppColors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        _getDifficultyText(session.type.difficulty, isTr),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress and Stats Row
            Row(
              children: [
                // Progress Section
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${session.currentQuestionIndex + 1}/${session.questions.length}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '%${(session.progress * 100).toInt()}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: session.progress.clamp(0, 1),
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Stats Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCompactStatItem(
                      icon: Icons.check_circle,
                      value: session.correctAnswers.toString(),
                      color: AppColors.glowGreen,
                    ),
                    const SizedBox(width: 6),
                    _buildCompactStatItem(
                      icon: Icons.cancel,
                      value: session.wrongAnswers.toString(),
                      color: AppColors.powderRed,
                    ),
                    const SizedBox(width: 6),
                    _buildCompactStatItem(
                      icon: Icons.favorite,
                      value: (session.maxWrongAnswers - session.wrongAnswers)
                          .toString(),
                      color: AppColors.pink,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(String difficulty, bool isTr) {
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

/// Modern quiz content widget similar to Puzzle Content
class _ModernQuizContent extends StatelessWidget {
  final QuizSession session;
  final QuizProvider quizProvider;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const _ModernQuizContent({
    required this.session,
    required this.quizProvider,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Question Card - Fixed height to prevent overflow
        if (session.currentQuestion != null)
          Flexible(flex: 2, child: _buildModernQuestionCard(context)),

        const SizedBox(height: 16),

        // Answer Options - Fixed height to prevent overflow
        if (session.currentQuestion != null)
          Flexible(flex: 3, child: _buildModernAnswerOptions(context)),

        const SizedBox(height: 16),

        // Refresh Button - Fixed at bottom
        if (session.currentQuestion != null) _buildRefreshButton(context),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildModernQuestionCard(BuildContext context) {
    final question = session.currentQuestion!;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Element display - Simple square container
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.darkTurquoise,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.turquoise.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkTurquoise.withValues(alpha: 0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      color: AppColors.turquoise,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAnswerOptions(BuildContext context) {
    final colors = _getQuizTypeColors(session.type);
    final question = session.currentQuestion!;

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Vertical layout - 4 options stacked
              Expanded(
                child: _buildModernOptionButton(
                  context,
                  option: question.options[0],
                  isSelected: session.selectedAnswer == question.options[0],
                  isCorrect:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      question.options[0] == question.correctAnswer,
                  isWrong:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      session.selectedAnswer == question.options[0] &&
                      question.options[0] != question.correctAnswer,
                  width: double.infinity,
                  height: double.infinity,
                  colors: colors,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildModernOptionButton(
                  context,
                  option: question.options[1],
                  isSelected: session.selectedAnswer == question.options[1],
                  isCorrect:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      question.options[1] == question.correctAnswer,
                  isWrong:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      session.selectedAnswer == question.options[1] &&
                      question.options[1] != question.correctAnswer,
                  width: double.infinity,
                  height: double.infinity,
                  colors: colors,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildModernOptionButton(
                  context,
                  option: question.options[2],
                  isSelected: session.selectedAnswer == question.options[2],
                  isCorrect:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      question.options[2] == question.correctAnswer,
                  isWrong:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      session.selectedAnswer == question.options[2] &&
                      question.options[2] != question.correctAnswer,
                  width: double.infinity,
                  height: double.infinity,
                  colors: colors,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _buildModernOptionButton(
                  context,
                  option: question.options[3],
                  isSelected: session.selectedAnswer == question.options[3],
                  isCorrect:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      question.options[3] == question.correctAnswer,
                  isWrong:
                      (session.state == QuizState.correct ||
                          session.state == QuizState.incorrect) &&
                      session.selectedAnswer == question.options[3] &&
                      question.options[3] != question.correctAnswer,
                  width: double.infinity,
                  height: double.infinity,
                  colors: colors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (!quizProvider.canRefreshQuestion) {
          return const SizedBox.shrink();
        }

        final isTr = context.watch<LocalizationProvider>().isTr;
        final colors = _getQuizTypeColors(session.type);

        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<QuizProvider>().refreshCurrentQuestion();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary.withValues(alpha: 0.8),
                        colors.primary.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTr ? 'Soruyu Yenile' : 'Refresh Question',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernOptionButton(
    BuildContext context, {
    required String option,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
    required double width,
    required double height,
    required ({Color primary, Color shadow}) colors,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (isCorrect) {
      backgroundColor = AppColors.glowGreen.withValues(alpha: 0.2);
      borderColor = AppColors.glowGreen;
      textColor = AppColors.glowGreen;
      icon = Icons.check_circle;
    } else if (isWrong) {
      backgroundColor = AppColors.powderRed.withValues(alpha: 0.2);
      borderColor = AppColors.powderRed;
      textColor = AppColors.powderRed;
      icon = Icons.cancel;
    } else if (isSelected) {
      backgroundColor = colors.primary.withValues(alpha: 0.2);
      borderColor = colors.primary;
      textColor = colors.primary;
    } else {
      backgroundColor = AppColors.white.withValues(alpha: 0.1);
      borderColor = AppColors.white.withValues(alpha: 0.3);
      textColor = AppColors.white;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: session.state == QuizState.loaded
            ? () {
                HapticFeedback.lightImpact();
                quizProvider.submitAnswer(option);
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected || isCorrect || isWrong ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
              if (isSelected || isCorrect || isWrong)
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.4),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Stack(
            children: [
              // Option content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: textColor, size: 16),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      option,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected && !isCorrect && !isWrong)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeText(QuizType type, bool isTr) {
    switch (type) {
      case QuizType.symbol:
        return isTr ? 'Sembol Testi' : 'Symbol Test';
      case QuizType.group:
        return isTr ? 'Grup Testi' : 'Group Test';
      case QuizType.number:
        return isTr ? 'Numara Testi' : 'Number Test';
    }
  }

  String _getQuestionHint(QuizType type, bool isTr) {
    switch (type) {
      case QuizType.symbol:
        return isTr
            ? 'Element sembolüne göre doğru elementi seçin'
            : 'Select the correct element based on its symbol';
      case QuizType.group:
        return isTr
            ? 'Element adına göre doğru grubu seçin'
            : 'Select the correct group based on the element name';
      case QuizType.number:
        return isTr
            ? 'Atom numarasına göre doğru elementi seçin'
            : 'Select the correct element based on its atomic number';
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

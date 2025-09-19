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
import 'package:elements_app/feature/view/elementsList/elements_loading_view.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/product/constants/stringConstants/en_app_strings.dart';
import 'package:elements_app/product/constants/stringConstants/tr_app_strings.dart';
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
      );
    });
  }

  void _startNewQuiz() {
    // Reset the quiz provider completely and start fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizProvider = context.read<QuizProvider>();
      quizProvider.resetQuiz();
      // Start a completely new quiz session
      quizProvider.startQuiz(widget.quizType, first20Only: widget.first20Only);
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
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    maxHeight: 600,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ElementsLoadingView(),
                      const SizedBox(height: 24),
                      Text(
                        context.watch<LocalizationProvider>().isTr
                            ? TrAppStrings.loadingQuiz
                            : EnAppStrings.loadingQuiz,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.watch<LocalizationProvider>().isTr
                            ? widget.quizType.turkishTitle
                            : widget.quizType.englishTitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
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
                  // Quiz Header - Daha uzun alan
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: QuizHeader(
                      session: session,
                      onClose: () => _handleQuizExit(context, quizProvider),
                    ),
                  ),

                  // Question and Options - Kalan alanı kullan
                  Expanded(
                    child: Column(
                      children: [
                        // Question Card - Ekranın 1/3'ü
                        if (session.currentQuestion != null)
                          Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: QuestionCard(
                              question: session.currentQuestion!,
                              state: session.state,
                            ),
                          ),

                        // Answer Options - Kalan alan
                        if (session.currentQuestion != null)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: AnswerOptionsGrid(
                                question: session.currentQuestion!,
                                selectedAnswer: session.selectedAnswer,
                                state: session.state,
                                onAnswerSelected: (answer) {
                                  // Add haptic feedback for better UX
                                  HapticFeedback.lightImpact();
                                  quizProvider.submitAnswer(answer);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Refresh Button (once per session) - Sabit yükseklik
                  if (quizProvider.canRefreshQuestion)
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.read<QuizProvider>().refreshCurrentQuestion();
                        },
                        backgroundColor: AppColors.yellow,
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.background,
                        ),
                        label: Text(
                          context.watch<LocalizationProvider>().isTr
                              ? 'Yenile'
                              : 'Refresh',
                          style: const TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
    context.read<AdmobProvider>().onRouteChanged();
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

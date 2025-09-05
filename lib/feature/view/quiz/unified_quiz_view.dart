import 'package:elements_app/feature/view/quiz/modern_quiz_home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/quiz_provider.dart';
import 'package:elements_app/feature/provider/admob_provider.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/widget/quiz/quiz_components.dart';
import 'package:elements_app/product/widget/loadingBar/loading_chemistry.dart';
import 'package:elements_app/product/constants/app_colors.dart';

/// Unified quiz view that handles all quiz types with modern UI
class UnifiedQuizView extends StatefulWidget {
  final QuizType quizType;

  const UnifiedQuizView({
    super.key,
    required this.quizType,
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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startQuiz();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _startQuiz() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().startQuiz(widget.quizType);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingChemistry(size: 120),
            const SizedBox(height: 24),
            Text(
              'Quiz hazırlanıyor...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.quizType.turkishTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.powderRed,
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Yüklenemedi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                            color: AppColors.white.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Geri Dön',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Tekrar Dene',
                        style: TextStyle(
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
    );
  }

  Widget _buildQuizState(
      BuildContext context, QuizProvider quizProvider, QuizSession session) {
    // Show result dialog if quiz is completed or failed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (session.isCompleted &&
          (session.state == QuizState.completed ||
              session.state == QuizState.failed)) {
        _showResultDialog(context, quizProvider, session);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Quiz Header - Daha kompakt
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AnswerOptionsGrid(
                            question: session.currentQuestion!,
                            selectedAnswer: session.selectedAnswer,
                            state: session.state,
                            onAnswerSelected: (answer) {
                              quizProvider.submitAnswer(answer);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Retry Button (if available) - Sabit yükseklik
              if (quizProvider.canRetry)
                Container(
                  height: 80,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: FloatingActionButton.extended(
                    onPressed: () => quizProvider.retryQuestion(),
                    backgroundColor: AppColors.yellow,
                    icon: Icon(Icons.refresh, color: AppColors.background),
                    label: Text(
                      'Tekrar Dene (${session.retryCount})',
                      style: TextStyle(
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
    );
  }

  void _showResultDialog(
      BuildContext context, QuizProvider quizProvider, QuizSession session) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizResultDialog(
        session: session,
        onRestart: () {
          Navigator.of(context).pop(); // Close dialog
          quizProvider.resetQuiz();
          _startQuiz();
        },
        onHome: () {
          Navigator.of(context).pop(); // Close dialog
          _navigateToHome(context, quizProvider);
        },
      ),
    );
  }

  void _handleQuizExit(BuildContext context, QuizProvider quizProvider) {
    if (quizProvider.hasActiveSession) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Quiz\'den Çık',
            style:
                TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Quiz\'i şimdi bırakırsanız ilerlemeniz kaybolacak. Emin misiniz?',
            style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'İptal',
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
                'Çık',
                style: TextStyle(
                    color: AppColors.white, fontWeight: FontWeight.w600),
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
      MaterialPageRoute(builder: (context) => const ModernQuizHome()),
      (route) => false,
    );
  }
}

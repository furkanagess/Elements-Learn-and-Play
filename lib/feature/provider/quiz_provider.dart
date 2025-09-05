import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/feature/service/quiz/quiz_service.dart';
import 'package:elements_app/product/constants/api_types.dart';

/// Provider class for managing quiz state and operations
class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  QuizSession? _currentSession;
  Map<QuizType, QuizStatistics> _statistics = {};
  // Getters
  QuizSession? get currentSession => _currentSession;
  Map<QuizType, QuizStatistics> get statistics => _statistics;

  bool get hasActiveSession => _currentSession != null;
  QuizQuestion? get currentQuestion => _currentSession?.currentQuestion;
  QuizState get currentState => _currentSession?.state ?? QuizState.initial;
  bool get isLoading => currentState == QuizState.loading;
  bool get canRetry => (_currentSession?.retryCount ?? 0) > 0;

  /// Starts a new quiz session
  Future<void> startQuiz(QuizType type) async {
    try {
      _updateSessionState(QuizState.loading);

      final apiUrl = _getApiUrlForQuizType(type);
      final questions = await _quizService.generateQuestions(
        type: type,
        apiUrl: apiUrl,
      );

      _currentSession = _quizService.createQuizSession(
        type: type,
        questions: questions,
      );

      _updateSessionState(QuizState.loaded);
      debugPrint('✅ Quiz started: ${type.turkishTitle}');
    } catch (e) {
      _updateSessionState(QuizState.error);
      _currentSession = _currentSession?.copyWith(
        errorMessage: e.toString(),
      );
      debugPrint('❌ Error starting quiz: $e');
    }
  }

  /// Submits an answer for the current question
  void submitAnswer(String selectedAnswer) {
    if (_currentSession == null || currentQuestion == null) return;

    _updateSessionState(QuizState.answering);

    final isCorrect =
        _quizService.validateAnswer(currentQuestion!, selectedAnswer);

    _currentSession = _currentSession!.copyWith(
      selectedAnswer: selectedAnswer,
      correctAnswers: isCorrect
          ? _currentSession!.correctAnswers + 1
          : _currentSession!.correctAnswers,
      wrongAnswers: !isCorrect
          ? _currentSession!.wrongAnswers + 1
          : _currentSession!.wrongAnswers,
    );

    if (isCorrect) {
      _updateSessionState(QuizState.correct);
      debugPrint('✅ Correct answer: $selectedAnswer');
    } else {
      _updateSessionState(QuizState.incorrect);
      debugPrint(
          '❌ Wrong answer: $selectedAnswer (correct: ${currentQuestion!.correctAnswer})');
    }

    // Auto-advance to next question after a delay
    Timer(const Duration(seconds: 2), () {
      _moveToNextQuestion();
    });
  }

  /// Moves to the next question or completes the quiz
  void _moveToNextQuestion() {
    if (_currentSession == null) return;

    // Check if quiz should end
    if (_currentSession!.isFailed) {
      _endQuiz(QuizState.failed);
      return;
    }

    // Move to next question
    final nextIndex = _currentSession!.currentQuestionIndex + 1;

    if (nextIndex >= _currentSession!.questions.length) {
      _endQuiz(QuizState.completed);
      return;
    }

    _currentSession = _currentSession!.copyWith(
      currentQuestionIndex: nextIndex,
      selectedAnswer: null,
    );

    _updateSessionState(QuizState.loaded);
  }

  /// Ends the current quiz session
  void _endQuiz(QuizState endState) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      state: endState,
      endTime: DateTime.now(),
    );

    _updateStatistics();

    debugPrint('🏁 Quiz ended: ${endState.name}');
    debugPrint(
        '📊 Score: ${_currentSession!.correctAnswers}/${_currentSession!.questions.length}');
  }

  /// Retries the current question
  void retryQuestion() {
    if (_currentSession == null || !canRetry) return;

    _currentSession = _currentSession!.copyWith(
      retryCount: _currentSession!.retryCount - 1,
      selectedAnswer: null,
    );

    _updateSessionState(QuizState.loaded);
    debugPrint(
        '🔄 Question retried. Retries left: ${_currentSession!.retryCount}');
  }

  /// Resets the current quiz session
  void resetQuiz() {
    _currentSession = null;
    notifyListeners();

    debugPrint('🔄 Quiz reset');
  }

  /// Updates session state and notifies listeners
  void _updateSessionState(QuizState newState) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(state: newState);
      notifyListeners();
    }
  }

  /// Gets API URL for specific quiz type
  String _getApiUrlForQuizType(QuizType type) {
    switch (type) {
      case QuizType.symbol:
        return ApiTypes.allElements;
      case QuizType.group:
        return ApiTypes.allElements;
      case QuizType.number:
        return ApiTypes.allElements;
    }
  }

  /// Updates quiz statistics after session completion
  void _updateStatistics() {
    if (_currentSession == null) return;

    final type = _currentSession!.type;
    final currentStats = _statistics[type] ?? QuizStatistics(type: type);

    final isWin = _currentSession!.state == QuizState.completed;
    final newStreak = isWin ? currentStats.currentStreak + 1 : 0;
    final score = _currentSession!.scorePercentage * 100;

    _statistics[type] = currentStats.copyWith(
      totalGamesPlayed: currentStats.totalGamesPlayed + 1,
      totalCorrectAnswers:
          currentStats.totalCorrectAnswers + _currentSession!.correctAnswers,
      totalWrongAnswers:
          currentStats.totalWrongAnswers + _currentSession!.wrongAnswers,
      totalTimePlayed: currentStats.totalTimePlayed + _currentSession!.duration,
      bestScore:
          score > currentStats.bestScore ? score : currentStats.bestScore,
      bestTime: _currentSession!.duration < currentStats.bestTime ||
              currentStats.bestTime == Duration.zero
          ? _currentSession!.duration
          : currentStats.bestTime,
      currentStreak: newStreak,
      longestStreak: newStreak > currentStats.longestStreak
          ? newStreak
          : currentStats.longestStreak,
    );

    notifyListeners();
  }

  /// Gets statistics for a specific quiz type
  QuizStatistics getStatisticsForType(QuizType type) {
    return _statistics[type] ?? QuizStatistics(type: type);
  }

  /// Gets total games played across all quiz types
  int getTotalGamesPlayed() {
    return _statistics.values
        .fold(0, (sum, stats) => sum + stats.totalGamesPlayed);
  }

  /// Gets average accuracy across all quiz types
  double getAverageAccuracy() {
    if (_statistics.isEmpty) return 0.0;
    final accuracies =
        _statistics.values.map((stats) => stats.accuracy).toList();
    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  /// Gets total streak across all quiz types
  int getTotalStreak() {
    return _statistics.values
        .fold(0, (sum, stats) => sum + stats.currentStreak);
  }

  /// Gets best score across all quiz types
  double getBestScore() {
    if (_statistics.isEmpty) return 0.0;
    return _statistics.values
        .map((stats) => stats.bestScore)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Clears all statistics
  void clearStatistics() {
    _statistics.clear();
    notifyListeners();

    debugPrint('🗑️ Statistics cleared');
  }

  /// Gets formatted time string
  String getFormattedTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Gets progress percentage as string
  String getProgressPercentage() {
    if (_currentSession == null) return '0%';
    return '${(_currentSession!.progress * 100).toInt()}%';
  }

  /// Gets current question number
  String getCurrentQuestionNumber() {
    if (_currentSession == null) return '0/0';
    return '${_currentSession!.currentQuestionIndex + 1}/${_currentSession!.questions.length}';
  }

  /// Disposes the provider and cleans up resources
  @override
  void dispose() {
    super.dispose();
  }
}

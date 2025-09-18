import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:elements_app/feature/service/quiz/quiz_service.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:elements_app/product/widget/ads/interstitial_ad_widget.dart';

/// Provider class for managing quiz state and operations
class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();
  final String _storageKey = 'quiz_statistics';
  final String _achievementsStorageKey = 'quiz_achievements';
  late SharedPreferences _prefs;

  QuizSession? _currentSession;
  Map<QuizType, QuizStatistics> _statistics = {};
  Map<QuizType, List<QuizBadge>> _achievements = {};
  List<QuizBadge> _lastEarnedBadges = [];
  final Map<QuizType, List<PeriodicElement>> _elementsCache = {};
  bool _refreshUsedInSession = false;

  QuizProvider() {
    _initPrefs();
  }

  /// Initialize SharedPreferences and load cached statistics
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStatistics();
    _loadAchievements();
  }

  /// Load statistics from SharedPreferences cache
  void _loadStatistics() {
    final String? statisticsJson = _prefs.getString(_storageKey);
    if (statisticsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(statisticsJson);
        _statistics = decoded.map((key, value) {
          final quizType = QuizType.values.firstWhere(
            (type) => type.name == key,
            orElse: () => QuizType.symbol,
          );
          return MapEntry(quizType, QuizStatistics.fromJson(value));
        });
        debugPrint('📊 Loaded cached quiz statistics');
        // Evaluate achievements against loaded stats
        for (final t in _statistics.keys) {
          _evaluateAndAwardBadges(t);
        }
      } catch (e) {
        debugPrint('❌ Error loading cached statistics: $e');
        _statistics = {};
      }
    }
  }

  /// Save statistics to SharedPreferences cache
  Future<void> _saveStatistics() async {
    try {
      final Map<String, dynamic> statisticsMap = _statistics.map(
        (key, value) => MapEntry(key.name, value.toJson()),
      );
      final String encoded = jsonEncode(statisticsMap);
      await _prefs.setString(_storageKey, encoded);
      debugPrint('💾 Saved quiz statistics to cache');
    } catch (e) {
      debugPrint('❌ Error saving statistics: $e');
    }
  }

  /// Load achievements from SharedPreferences cache
  void _loadAchievements() {
    final String? jsonStr = _prefs.getString(_achievementsStorageKey);
    if (jsonStr != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        _achievements = decoded.map((key, value) {
          final type = QuizType.values.firstWhere(
            (t) => t.name == key,
            orElse: () => QuizType.symbol,
          );
          final list = (value as List)
              .map((e) => QuizBadge.fromJson(e as Map<String, dynamic>))
              .toList();
          return MapEntry(type, list);
        });
      } catch (e) {
        debugPrint('❌ Error loading achievements: $e');
        _achievements = {};
      }
    }
  }

  /// Save achievements to SharedPreferences cache
  Future<void> _saveAchievements() async {
    try {
      // ensure defaults present
      for (final t in QuizType.values) {
        _achievements[t] = _achievements[t] ?? _defaultBadgesForType(t);
      }
      final data = _achievements.map(
        (key, value) =>
            MapEntry(key.name, value.map((b) => b.toJson()).toList()),
      );
      await _prefs.setString(_achievementsStorageKey, jsonEncode(data));
    } catch (e) {
      debugPrint('❌ Error saving achievements: $e');
    }
  }

  // Getters
  QuizSession? get currentSession => _currentSession;
  Map<QuizType, QuizStatistics> get statistics => _statistics;
  Map<QuizType, List<QuizBadge>> get achievements => _achievements;
  List<QuizBadge> get lastEarnedBadges => List.unmodifiable(_lastEarnedBadges);

  /// Returns and clears badges earned during the last evaluation
  List<QuizBadge> consumeLastEarnedBadges() {
    final res = List<QuizBadge>.from(_lastEarnedBadges);
    _lastEarnedBadges.clear();
    return res;
  }

  bool get hasActiveSession => _currentSession != null;
  QuizQuestion? get currentQuestion => _currentSession?.currentQuestion;
  QuizState get currentState => _currentSession?.state ?? QuizState.initial;
  bool get isLoading => currentState == QuizState.loading;
  bool get canRetry => (_currentSession?.retryCount ?? 0) > 0;
  bool get canRefreshQuestion =>
      !_refreshUsedInSession &&
      _currentSession != null &&
      (currentState == QuizState.loaded ||
          currentState == QuizState.correct ||
          currentState == QuizState.incorrect ||
          currentState == QuizState.answering);

  /// Starts a new quiz session
  Future<void> startQuiz(QuizType type) async {
    try {
      // Ensure we start completely fresh
      _currentSession = null;
      _updateSessionState(QuizState.loading);
      _refreshUsedInSession = false;

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
      debugPrint('✅ New quiz started from scratch: ${type.turkishTitle}');
      debugPrint('📊 Questions loaded: ${questions.length}');
    } catch (e) {
      _updateSessionState(QuizState.error);
      _currentSession = _currentSession?.copyWith(errorMessage: e.toString());
      debugPrint('❌ Error starting quiz: $e');
    }
  }

  /// Starts a new quiz session with specific retry count
  Future<void> _startQuizWithRetryCount(QuizType type, int retryCount) async {
    try {
      // Ensure we start completely fresh
      _currentSession = null;
      _updateSessionState(QuizState.loading);
      _refreshUsedInSession = false;

      final apiUrl = _getApiUrlForQuizType(type);
      final questions = await _quizService.generateQuestions(
        type: type,
        apiUrl: apiUrl,
      );

      _currentSession = _quizService.createQuizSession(
        type: type,
        questions: questions,
      );

      // Update retry count to the specified value
      _currentSession = _currentSession!.copyWith(retryCount: retryCount);

      _updateSessionState(QuizState.loaded);
      debugPrint('✅ Quiz restarted with retry count: $retryCount');
      debugPrint('📊 Questions loaded: ${questions.length}');
    } catch (e) {
      _updateSessionState(QuizState.error);
      _currentSession = _currentSession?.copyWith(errorMessage: e.toString());
      debugPrint('❌ Error restarting quiz: $e');
    }
  }

  /// Submits an answer for the current question
  void submitAnswer(String selectedAnswer) {
    if (_currentSession == null || currentQuestion == null) return;

    _updateSessionState(QuizState.answering);

    final isCorrect = _quizService.validateAnswer(
      currentQuestion!,
      selectedAnswer,
    );

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
        '❌ Wrong answer: $selectedAnswer (correct: ${currentQuestion!.correctAnswer})',
      );
    }

    // Auto-advance to next question after a shorter delay for better UX
    Timer(const Duration(milliseconds: 1200), () {
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

    // Check if all questions are answered (quiz completed)
    if (nextIndex >= _currentSession!.questions.length) {
      debugPrint('🏁 All questions answered! Quiz completed.');
      _endQuiz(QuizState.completed);
      return;
    }

    _currentSession = _currentSession!.copyWith(
      currentQuestionIndex: nextIndex,
      selectedAnswer: null,
    );

    _updateSessionState(QuizState.loaded);
    debugPrint(
      '➡️ Moved to question ${nextIndex + 1}/${_currentSession!.questions.length}',
    );
  }

  /// Ends the current quiz session
  void _endQuiz(QuizState endState) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      state: endState,
      endTime: DateTime.now(),
    );

    _updateStatistics();
    _evaluateAndAwardBadges(_currentSession!.type);

    debugPrint('🏁 Quiz ended: ${endState.name}');
    debugPrint(
      '📊 Score: ${_currentSession!.correctAnswers}/${_currentSession!.questions.length}',
    );
    debugPrint(
      '📊 Questions answered: ${_currentSession!.correctAnswers + _currentSession!.wrongAnswers}',
    );
    debugPrint(
      '📊 Current question index: ${_currentSession!.currentQuestionIndex}',
    );
    debugPrint('📊 Total questions: ${_currentSession!.questions.length}');
    debugPrint('📊 Is completed: ${_currentSession!.isCompleted}');

    // Pre-load next interstitial ad for better user experience
    if (endState == QuizState.completed) {
      debugPrint('🎯 Pre-loading next interstitial ad for quiz completion');
      InterstitialAdWidget.loadInterstitialAd();
    }

    // Force notify listeners to trigger UI update
    notifyListeners();
  }

  /// Retries the current question (legacy method - now restarts entire quiz)
  void retryQuestion() {
    if (_currentSession == null || !canRetry) return;

    _currentSession = _currentSession!.copyWith(
      retryCount: _currentSession!.retryCount - 1,
      selectedAnswer: null,
    );

    _updateSessionState(QuizState.loaded);
    debugPrint(
      '🔄 Question retried. Retries left: ${_currentSession!.retryCount}',
    );
  }

  /// Restarts the entire quiz from the beginning
  void restartQuizFromBeginning() {
    if (_currentSession == null) return;

    // Store quiz type and retry count before resetting
    final quizType = _currentSession!.type;
    final newRetryCount = _currentSession!.retryCount - 1;

    debugPrint(
      '🔄 Quiz restarted from beginning. Retries left: $newRetryCount',
    );

    // Start a new quiz with the same type and updated retry count
    _startQuizWithRetryCount(quizType, newRetryCount);
  }

  /// Refreshes the current question by generating a new one
  Future<void> refreshCurrentQuestion() async {
    if (_currentSession == null) return;
    if (_refreshUsedInSession) return; // one-time per session

    try {
      final type = _currentSession!.type;
      final apiUrl = _getApiUrlForQuizType(type);

      // Lazy-load and cache the elements for this quiz type
      if (!_elementsCache.containsKey(type) || _elementsCache[type]!.isEmpty) {
        _elementsCache[type] = await _quizService.fetchElements(apiUrl);
      }

      final pool = _elementsCache[type]!;
      final idx = _currentSession!.currentQuestionIndex;
      final oldQuestion = _currentSession!.questions[idx];

      // Generate a different question (try a few times to avoid same answer)
      QuizQuestion newQuestion = _quizService
          .generateSingleQuestionFromElements(
            elements: pool,
            type: type,
            questionId: 'q_refresh_${DateTime.now().millisecondsSinceEpoch}',
          );
      int attempts = 0;
      while (attempts < 5 &&
          newQuestion.correctAnswer.toLowerCase() ==
              oldQuestion.correctAnswer.toLowerCase()) {
        newQuestion = _quizService.generateSingleQuestionFromElements(
          elements: pool,
          type: type,
          questionId:
              'q_refresh_${DateTime.now().millisecondsSinceEpoch}_$attempts',
        );
        attempts++;
      }

      final updatedQuestions = List<QuizQuestion>.from(
        _currentSession!.questions,
      );
      updatedQuestions[idx] = newQuestion;

      _currentSession = _currentSession!.copyWith(
        questions: updatedQuestions,
        selectedAnswer: null,
      );

      _refreshUsedInSession = true; // consume refresh
      notifyListeners(); // Update UI without toggling loading state
      debugPrint('🔄 Current question refreshed (once per session).');
    } catch (e) {
      // keep current state; attach error for visibility
      _currentSession = _currentSession?.copyWith(
        errorMessage: 'Failed to refresh question: $e',
      );
      notifyListeners();
      debugPrint('❌ Error refreshing current question: $e');
    }
  }

  /// Resets the current quiz session
  void resetQuiz() {
    _currentSession = null;
    notifyListeners();

    debugPrint('🔄 Quiz reset - Starting fresh');
  }

  /// Grants one extra life and resumes the current question after rewarded ad.
  /// - Increases maxWrongAnswers by 1 (adds a life)
  /// - Replaces the current question with a fresh one so user continues on a NEW question
  /// - Clears selectedAnswer and failed/end state
  /// - Sets state back to loaded
  void continueAfterReward() {
    if (_currentSession == null) return;
    final s = _currentSession!;
    // Add a life by increasing the cap
    final updated = s.copyWith(
      maxWrongAnswers: s.maxWrongAnswers + 1,
      selectedAnswer: null,
      endTime: null,
      state: QuizState.loaded,
    );
    _currentSession = updated;
    // Replace current question without consuming user refresh allowance
    _replaceCurrentQuestionForReward();
    notifyListeners();
    debugPrint('🧪 Reward continue applied: +1 life, moved to a new question');
  }

  /// Internal: Generate a new question for the current index without
  /// consuming the one-time _refreshUsedInSession flag.
  Future<void> _replaceCurrentQuestionForReward() async {
    if (_currentSession == null) return;
    try {
      final type = _currentSession!.type;
      final apiUrl = _getApiUrlForQuizType(type);

      // Lazy-load and cache elements
      if (!_elementsCache.containsKey(type) || _elementsCache[type]!.isEmpty) {
        _elementsCache[type] = await _quizService.fetchElements(apiUrl);
      }

      final pool = _elementsCache[type]!;
      final idx = _currentSession!.currentQuestionIndex;
      final oldQuestion = _currentSession!.questions[idx];

      QuizQuestion newQuestion = _quizService
          .generateSingleQuestionFromElements(
            elements: pool,
            type: type,
            questionId: 'q_reward_${DateTime.now().millisecondsSinceEpoch}',
          );
      int attempts = 0;
      while (attempts < 5 &&
          newQuestion.correctAnswer.toLowerCase() ==
              oldQuestion.correctAnswer.toLowerCase()) {
        newQuestion = _quizService.generateSingleQuestionFromElements(
          elements: pool,
          type: type,
          questionId:
              'q_reward_${DateTime.now().millisecondsSinceEpoch}_$attempts',
        );
        attempts++;
      }

      final updatedQuestions = List<QuizQuestion>.from(
        _currentSession!.questions,
      );
      final safeIdx = idx.clamp(0, updatedQuestions.length - 1);
      updatedQuestions[safeIdx] = newQuestion;

      _currentSession = _currentSession!.copyWith(
        questions: updatedQuestions,
        selectedAnswer: null,
        state: QuizState.loaded,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error replacing question after reward: $e');
    }
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
      bestScore: score > currentStats.bestScore
          ? score
          : currentStats.bestScore,
      bestTime:
          (isWin &&
              (_currentSession!.duration < currentStats.bestTime ||
                  currentStats.bestTime == Duration.zero))
          ? _currentSession!.duration
          : currentStats.bestTime,
      currentStreak: newStreak,
      longestStreak: newStreak > currentStats.longestStreak
          ? newStreak
          : currentStats.longestStreak,
    );

    // Save to cache after updating
    _saveStatistics();
    // Also persist achievements state in case changed elsewhere
    _saveAchievements();
    notifyListeners();
  }

  /// Gets statistics for a specific quiz type
  QuizStatistics getStatisticsForType(QuizType type) {
    return _statistics[type] ?? QuizStatistics(type: type);
  }

  /// Gets total games played across all quiz types
  int getTotalGamesPlayed() {
    return _statistics.values.fold(
      0,
      (sum, stats) => sum + stats.totalGamesPlayed,
    );
  }

  /// Gets average accuracy across all quiz types
  double getAverageAccuracy() {
    if (_statistics.isEmpty) return 0.0;
    final accuracies = _statistics.values
        .map((stats) => stats.accuracy)
        .toList();
    return accuracies.reduce((a, b) => a + b) / accuracies.length;
  }

  /// Gets total streak across all quiz types
  int getTotalStreak() {
    return _statistics.values.fold(
      0,
      (sum, stats) => sum + stats.currentStreak,
    );
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
    _prefs.remove(_storageKey);
    // Do not clear achievements definitions, only earned flags if needed.
    notifyListeners();

    debugPrint('🗑️ Statistics cleared from memory and cache');
  }

  /// Clears all achievements (resets earned status)
  void clearAchievements() {
    _achievements.clear();
    _prefs.remove(_achievementsStorageKey);
    notifyListeners();
    debugPrint('🗑️ Achievements cleared from memory and cache');
  }

  /// Clears both statistics and achievements
  void clearAllData() {
    clearStatistics();
    clearAchievements();
    debugPrint('🗑️ All quiz data cleared');
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

  // ===================== Achievements logic =====================

  /// Returns badges for a type, ensuring defaults exist
  List<QuizBadge> getAchievementsForType(QuizType type) {
    _achievements[type] = _achievements[type] ?? _defaultBadgesForType(type);
    return _achievements[type]!;
  }

  /// Total earned badges across all quiz types
  int getTotalEarnedBadges() {
    for (final t in QuizType.values) {
      _achievements[t] = _achievements[t] ?? _defaultBadgesForType(t);
    }
    return _achievements.values
        .expand((list) => list)
        .where((b) => b.earned)
        .length;
  }

  /// Total badges available
  int getTotalBadgesCount() {
    for (final t in QuizType.values) {
      _achievements[t] = _achievements[t] ?? _defaultBadgesForType(t);
    }
    return _achievements.values.expand((e) => e).length;
  }

  /// Evaluate and mark badges as earned based on current statistics
  void _evaluateAndAwardBadges(QuizType type) {
    final stats = getStatisticsForType(type);
    final badges = getAchievementsForType(type);
    final previousById = {for (final b in badges) b.id: b};

    bool changed = false;
    QuizBadge setEarned(QuizBadge b) => b.copyWith(
      earned: true,
      earnedAt: b.earned ? b.earnedAt : DateTime.now(),
    );

    // Helper thresholds
    final accuracyPct = (stats.accuracy * 100).round();
    final games = stats.totalGamesPlayed;
    final streak = stats.currentStreak;
    final bestScore = stats.bestScore.round();
    final bestTimeSec = stats.bestTime.inSeconds;

    final updated = badges.map((b) {
      if (b.earned) return b;

      // Handle special achievements first
      if (b.id.startsWith('special_')) {
        switch (b.id) {
          case 'special_100_games':
            if (games >= 100) {
              changed = true;
              return setEarned(b);
            }
            break;
          case 'special_perfect_streak':
            // This would need additional tracking for perfect score streaks
            // For now, we'll use a simple approximation
            if (streak >= 10 && bestScore >= 100) {
              changed = true;
              return setEarned(b);
            }
            break;
          case 'special_lightning_fast':
            if (bestTimeSec > 0 && bestTimeSec <= 10) {
              changed = true;
              return setEarned(b);
            }
            break;
        }
        return b;
      }

      // Handle mastery_perfect achievement
      if (b.id == 'mastery_perfect') {
        // This would need additional tracking for multiple perfect scores
        // For now, we'll use a simple approximation based on games played and best score
        if (games >= 20 && bestScore >= 100) {
          changed = true;
          return setEarned(b);
        }
        return b;
      }

      // Regular achievements with id pattern: <cat>_<threshold>
      if (b.category == QuizBadgeCategory.games) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if (games >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == QuizBadgeCategory.accuracy) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if (accuracyPct >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == QuizBadgeCategory.streak) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if (streak >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == QuizBadgeCategory.mastery) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0; // bestScore
        if (bestScore >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == QuizBadgeCategory.speed) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0; // seconds
        if (bestTimeSec > 0 && bestTimeSec <= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      return b;
    }).toList();

    if (changed) {
      _achievements[type] = updated;
      // compute newly earned
      _lastEarnedBadges = [
        for (final b in updated)
          if (b.earned && (previousById[b.id]?.earned == false)) b,
      ];
      _saveAchievements();
      notifyListeners();
    } else {
      _lastEarnedBadges = [];
    }
  }

  /// Default badge set for a quiz type
  List<QuizBadge> _defaultBadgesForType(QuizType type) {
    // 24 badges per type: 6 games, 4 accuracy, 4 mastery, 4 streak, 3 speed, 3 special
    String mastery90En, mastery100En, masteryPerfectEn;
    String mastery90Tr, mastery100Tr, masteryPerfectTr;
    String speedLightningEn, speedThunderEn, speedFlashEn;
    String speedLightningTr, speedThunderTr, speedFlashTr;

    switch (type) {
      case QuizType.symbol:
        mastery90En = 'Symbol Savant';
        mastery90Tr = 'Sembol Üstadı';
        mastery100En = 'Symbol Master';
        mastery100Tr = 'Sembol Ustası';
        masteryPerfectEn = 'Symbol Legend';
        masteryPerfectTr = 'Sembol Efsanesi';
        speedLightningEn = 'Symbol Lightning';
        speedLightningTr = 'Sembol Şimşeği';
        speedThunderEn = 'Symbol Thunder';
        speedThunderTr = 'Sembol Gök Gürültüsü';
        speedFlashEn = 'Symbol Flash';
        speedFlashTr = 'Sembol Işık Hızı';
        break;
      case QuizType.group:
        mastery90En = 'Group Guru';
        mastery90Tr = 'Grup Gurusu';
        mastery100En = 'Group Master';
        mastery100Tr = 'Grup Ustası';
        masteryPerfectEn = 'Group Legend';
        masteryPerfectTr = 'Grup Efsanesi';
        speedLightningEn = 'Group Lightning';
        speedLightningTr = 'Grup Şimşeği';
        speedThunderEn = 'Group Thunder';
        speedThunderTr = 'Grup Gök Gürültüsü';
        speedFlashEn = 'Group Flash';
        speedFlashTr = 'Grup Işık Hızı';
        break;
      case QuizType.number:
        mastery90En = 'Atomic Numerist';
        mastery90Tr = 'Atom Numarası Üstadı';
        mastery100En = 'Atomic Master';
        mastery100Tr = 'Atom Ustası';
        masteryPerfectEn = 'Atomic Legend';
        masteryPerfectTr = 'Atom Efsanesi';
        speedLightningEn = 'Atomic Lightning';
        speedLightningTr = 'Atom Şimşeği';
        speedThunderEn = 'Atomic Thunder';
        speedThunderTr = 'Atom Gök Gürültüsü';
        speedFlashEn = 'Atomic Flash';
        speedFlashTr = 'Atom Işık Hızı';
        break;
    }

    return [
      // Games played milestones (6 badges)
      QuizBadge(
        id: 'games_1',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'First Experiment',
        titleTr: 'İlk Deney',
        descriptionEn: 'Play 1 game in this quiz',
        descriptionTr: 'Bu quizde 1 oyun oyna',
        icon: Icons.emoji_events,
      ),
      QuizBadge(
        id: 'games_5',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'Warming Reaction',
        titleTr: 'Isınan Reaksiyon',
        descriptionEn: 'Play 5 games in this quiz',
        descriptionTr: 'Bu quizde 5 oyun oyna',
        icon: Icons.emoji_events_outlined,
      ),
      QuizBadge(
        id: 'games_10',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'Periodic Explorer',
        titleTr: 'Periyodik Kaşif',
        descriptionEn: 'Play 10 games in this quiz',
        descriptionTr: 'Bu quizde 10 oyun oyna',
        icon: Icons.military_tech,
      ),
      QuizBadge(
        id: 'games_25',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'Lab Master',
        titleTr: 'Laboratuvar Ustası',
        descriptionEn: 'Play 25 games in this quiz',
        descriptionTr: 'Bu quizde 25 oyun oyna',
        icon: Icons.workspace_premium,
      ),
      QuizBadge(
        id: 'games_50',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'Research Pioneer',
        titleTr: 'Araştırma Öncüsü',
        descriptionEn: 'Play 50 games in this quiz',
        descriptionTr: 'Bu quizde 50 oyun oyna',
        icon: Icons.science,
      ),
      QuizBadge(
        id: 'games_100',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'Elemental Scholar',
        titleTr: 'Element Bilgini',
        descriptionEn: 'Play 100 games in this quiz',
        descriptionTr: 'Bu quizde 100 oyun oyna',
        icon: Icons.school,
      ),

      // Accuracy milestones (4 badges)
      QuizBadge(
        id: 'accuracy_60',
        type: type,
        category: QuizBadgeCategory.accuracy,
        titleEn: 'Pipette Pro',
        titleTr: 'Damlalık Ustası',
        descriptionEn: 'Reach 60% overall accuracy',
        descriptionTr: 'Genel doğrulukta %60\'a ulaş',
        icon: Icons.show_chart,
      ),
      QuizBadge(
        id: 'accuracy_80',
        type: type,
        category: QuizBadgeCategory.accuracy,
        titleEn: 'Precision Balance',
        titleTr: 'Hassas Terazi',
        descriptionEn: 'Reach 80% overall accuracy',
        descriptionTr: 'Genel doğrulukta %80\'e ulaş',
        icon: Icons.trending_up,
      ),
      QuizBadge(
        id: 'accuracy_95',
        type: type,
        category: QuizBadgeCategory.accuracy,
        titleEn: 'Laboratory Precision',
        titleTr: 'Laboratuvar Kesinliği',
        descriptionEn: 'Reach 95% overall accuracy',
        descriptionTr: 'Genel doğrulukta %95\'e ulaş',
        icon: Icons.auto_graph,
      ),
      QuizBadge(
        id: 'accuracy_100',
        type: type,
        category: QuizBadgeCategory.accuracy,
        titleEn: 'Quantum Precision',
        titleTr: 'Kuantum Kesinlik',
        descriptionEn: 'Reach 100% overall accuracy',
        descriptionTr: 'Genel doğrulukta %100\'e ulaş',
        icon: Icons.analytics,
      ),

      // Mastery milestones (4 badges)
      QuizBadge(
        id: 'mastery_70',
        type: type,
        category: QuizBadgeCategory.mastery,
        titleEn: 'Stable Isotope',
        titleTr: 'Kararlı İzotop',
        descriptionEn: 'Reach a best score of 70%',
        descriptionTr: 'En iyi skorda %70\'e ulaş',
        icon: Icons.star_half,
      ),
      QuizBadge(
        id: 'mastery_90',
        type: type,
        category: QuizBadgeCategory.mastery,
        titleEn: mastery90En,
        titleTr: mastery90Tr,
        descriptionEn: 'Reach a best score of 90%',
        descriptionTr: 'En iyi skorda %90\'a ulaş',
        icon: Icons.star,
      ),
      QuizBadge(
        id: 'mastery_100',
        type: type,
        category: QuizBadgeCategory.mastery,
        titleEn: mastery100En,
        titleTr: mastery100Tr,
        descriptionEn: 'Get a perfect best score',
        descriptionTr: 'En iyi skorda mükemmeli yakala',
        icon: Icons.stars,
      ),
      QuizBadge(
        id: 'mastery_perfect',
        type: type,
        category: QuizBadgeCategory.mastery,
        titleEn: masteryPerfectEn,
        titleTr: masteryPerfectTr,
        descriptionEn: 'Achieve perfect score multiple times',
        descriptionTr: 'Birden fazla kez mükemmel skor yap',
        icon: Icons.workspace_premium,
      ),

      // Streak milestones (4 badges)
      QuizBadge(
        id: 'streak_3',
        type: type,
        category: QuizBadgeCategory.streak,
        titleEn: 'Chain Reaction',
        titleTr: 'Zincir Tepkime',
        descriptionEn: 'Reach a win streak of 3',
        descriptionTr: '3 maçlık kazanma serisine ulaş',
        icon: Icons.local_fire_department,
      ),
      QuizBadge(
        id: 'streak_5',
        type: type,
        category: QuizBadgeCategory.streak,
        titleEn: 'Sustained Reaction',
        titleTr: 'Sürdürülen Reaksiyon',
        descriptionEn: 'Reach a win streak of 5',
        descriptionTr: '5 maçlık kazanma serisine ulaş',
        icon: Icons.whatshot,
      ),
      QuizBadge(
        id: 'streak_10',
        type: type,
        category: QuizBadgeCategory.streak,
        titleEn: 'Nuclear Chain',
        titleTr: 'Nükleer Zincir',
        descriptionEn: 'Reach a win streak of 10',
        descriptionTr: '10 maçlık kazanma serisine ulaş',
        icon: Icons.flash_on,
      ),
      QuizBadge(
        id: 'streak_20',
        type: type,
        category: QuizBadgeCategory.streak,
        titleEn: 'Fusion Master',
        titleTr: 'Füzyon Ustası',
        descriptionEn: 'Reach a win streak of 20',
        descriptionTr: '20 maçlık kazanma serisine ulaş',
        icon: Icons.bolt,
      ),

      // Speed milestones (3 badges)
      QuizBadge(
        id: 'speed_60',
        type: type,
        category: QuizBadgeCategory.speed,
        titleEn: 'Catalyst Runner',
        titleTr: 'Katalizör Koşucusu',
        descriptionEn: 'Finish a run under 60 seconds',
        descriptionTr: 'Bir oyunu 60 saniyenin altında bitir',
        icon: Icons.speed,
      ),
      QuizBadge(
        id: 'speed_30',
        type: type,
        category: QuizBadgeCategory.speed,
        titleEn: speedLightningEn,
        titleTr: speedLightningTr,
        descriptionEn: 'Finish a run under 30 seconds',
        descriptionTr: 'Bir oyunu 30 saniyenin altında bitir',
        icon: Icons.flash_on,
      ),
      QuizBadge(
        id: 'speed_15',
        type: type,
        category: QuizBadgeCategory.speed,
        titleEn: speedThunderEn,
        titleTr: speedThunderTr,
        descriptionEn: 'Finish a run under 15 seconds',
        descriptionTr: 'Bir oyunu 15 saniyenin altında bitir',
        icon: Icons.bolt,
      ),

      // Special achievements (3 badges)
      QuizBadge(
        id: 'special_100_games',
        type: type,
        category: QuizBadgeCategory.games,
        titleEn: 'Century Master',
        titleTr: 'Yüzyıl Ustası',
        descriptionEn: 'Play 100 games in this quiz',
        descriptionTr: 'Bu quizde 100 oyun oyna',
        icon: Icons.emoji_events,
      ),
      QuizBadge(
        id: 'special_perfect_streak',
        type: type,
        category: QuizBadgeCategory.streak,
        titleEn: 'Perfect Storm',
        titleTr: 'Mükemmel Fırtına',
        descriptionEn: 'Get 10 perfect scores in a row',
        descriptionTr: 'Arka arkaya 10 mükemmel skor yap',
        icon: Icons.storm,
      ),
      QuizBadge(
        id: 'special_lightning_fast',
        type: type,
        category: QuizBadgeCategory.speed,
        titleEn: speedFlashEn,
        titleTr: speedFlashTr,
        descriptionEn: 'Finish a run under 10 seconds',
        descriptionTr: 'Bir oyunu 10 saniyenin altında bitir',
        icon: Icons.electric_bolt,
      ),
    ];
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

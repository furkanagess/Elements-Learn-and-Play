import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Enum representing different types of quizzes
enum QuizType {
  symbol('Symbol Quiz', 'Atom Sembol Testi', Icons.science, 'Easy'),
  group('Group Quiz', 'Grup Testi', Icons.category, 'Medium'),
  number('Number Quiz', 'Atom Numara Testi', Icons.numbers, 'Hard');

  const QuizType(
      this.englishTitle, this.turkishTitle, this.icon, this.difficulty);

  final String englishTitle;
  final String turkishTitle;
  final IconData icon;
  final String difficulty;
}

/// Enum representing quiz states
enum QuizState {
  initial,
  loading,
  loaded,
  answering,
  correct,
  incorrect,
  completed,
  failed,
  error
}

/// Model representing a quiz question
class QuizQuestion extends Equatable {
  final String id;
  final String questionText;
  final String correctAnswer;
  final List<String> options;
  final QuizType type;
  final String? additionalInfo;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.type,
    this.additionalInfo,
  });

  QuizQuestion copyWith({
    String? id,
    String? questionText,
    String? correctAnswer,
    List<String>? options,
    QuizType? type,
    String? additionalInfo,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      type: type ?? this.type,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  List<Object?> get props =>
      [id, questionText, correctAnswer, options, type, additionalInfo];
}

/// Model representing quiz session data
class QuizSession extends Equatable {
  final String id;
  final QuizType type;
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int correctAnswers;
  final int wrongAnswers;
  final int maxWrongAnswers;
  final int retryCount;
  final int maxRetries;
  final QuizState state;
  final String? selectedAnswer;
  final DateTime startTime;
  final DateTime? endTime;
  final String? errorMessage;

  const QuizSession({
    required this.id,
    required this.type,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.maxWrongAnswers = 3,
    this.retryCount = 3,
    this.maxRetries = 3,
    this.state = QuizState.initial,
    this.selectedAnswer,
    required this.startTime,
    this.endTime,
    this.errorMessage,
  });

  QuizSession copyWith({
    String? id,
    QuizType? type,
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? correctAnswers,
    int? wrongAnswers,
    int? maxWrongAnswers,
    int? retryCount,
    int? maxRetries,
    QuizState? state,
    String? selectedAnswer,
    DateTime? startTime,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return QuizSession(
      id: id ?? this.id,
      type: type ?? this.type,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      maxWrongAnswers: maxWrongAnswers ?? this.maxWrongAnswers,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      state: state ?? this.state,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get current question
  QuizQuestion? get currentQuestion {
    if (currentQuestionIndex < questions.length) {
      return questions[currentQuestionIndex];
    }
    return null;
  }

  /// Check if quiz is completed
  bool get isCompleted =>
      currentQuestionIndex >= questions.length ||
      wrongAnswers >= maxWrongAnswers;

  /// Check if quiz is failed
  bool get isFailed => wrongAnswers >= maxWrongAnswers;

  /// Get quiz progress (0.0 to 1.0)
  double get progress {
    if (questions.isEmpty) return 0.0;
    return currentQuestionIndex / questions.length;
  }

  /// Get score percentage
  double get scorePercentage {
    final totalAnswered = correctAnswers + wrongAnswers;
    if (totalAnswered == 0) return 0.0;
    return correctAnswers / totalAnswered;
  }

  /// Get remaining lives
  int get remainingLives => maxWrongAnswers - wrongAnswers;

  /// Get quiz duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  @override
  List<Object?> get props => [
        id,
        type,
        questions,
        currentQuestionIndex,
        correctAnswers,
        wrongAnswers,
        maxWrongAnswers,
        retryCount,
        maxRetries,
        state,
        selectedAnswer,
        startTime,
        endTime,
        errorMessage,
      ];
}

/// Model representing quiz statistics
class QuizStatistics extends Equatable {
  final QuizType type;
  final int totalGamesPlayed;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final Duration totalTimePlayed;
  final double bestScore;
  final Duration bestTime;
  final int currentStreak;
  final int longestStreak;

  const QuizStatistics({
    required this.type,
    this.totalGamesPlayed = 0,
    this.totalCorrectAnswers = 0,
    this.totalWrongAnswers = 0,
    this.totalTimePlayed = Duration.zero,
    this.bestScore = 0.0,
    this.bestTime = Duration.zero,
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  QuizStatistics copyWith({
    QuizType? type,
    int? totalGamesPlayed,
    int? totalCorrectAnswers,
    int? totalWrongAnswers,
    Duration? totalTimePlayed,
    double? bestScore,
    Duration? bestTime,
    int? currentStreak,
    int? longestStreak,
  }) {
    return QuizStatistics(
      type: type ?? this.type,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      bestScore: bestScore ?? this.bestScore,
      bestTime: bestTime ?? this.bestTime,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  /// Get overall accuracy percentage
  double get accuracy {
    final total = totalCorrectAnswers + totalWrongAnswers;
    if (total == 0) return 0.0;
    return totalCorrectAnswers / total;
  }

  /// Get average time per game
  Duration get averageTimePerGame {
    if (totalGamesPlayed == 0) return Duration.zero;
    return Duration(
      milliseconds: totalTimePlayed.inMilliseconds ~/ totalGamesPlayed,
    );
  }

  @override
  List<Object?> get props => [
        type,
        totalGamesPlayed,
        totalCorrectAnswers,
        totalWrongAnswers,
        totalTimePlayed,
        bestScore,
        bestTime,
        currentStreak,
        longestStreak,
      ];
}

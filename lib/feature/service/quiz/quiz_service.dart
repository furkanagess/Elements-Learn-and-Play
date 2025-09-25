import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';

/// Service class responsible for quiz data management and business logic
class QuizService {
  static const int _defaultQuestionCount = 10;
  static const int _optionsPerQuestion = 4;

  /// Fetches elements from API and generates quiz questions
  Future<List<QuizQuestion>> generateQuestions({
    required QuizType type,
    required String apiUrl,
    int questionCount = _defaultQuestionCount,
    bool first20Only = false,
  }) async {
    try {
      var elements = await _fetchElements(apiUrl);
      if (first20Only) {
        elements = elements
            .where((e) => (e.number ?? 9999) <= 20)
            .toList(growable: false);
      }
      if (elements.isEmpty) {
        throw Exception('No elements found');
      }

      return _generateQuestionsFromElements(
        elements: elements,
        type: type,
        count: questionCount,
      );
    } catch (e) {
      debugPrint('Error generating questions: $e');
      rethrow;
    }
  }

  /// Fetches periodic elements from the API
  Future<List<PeriodicElement>> _fetchElements(String apiUrl) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((elementData) => PeriodicElement.fromJson(elementData))
            .toList();
      } else {
        throw Exception('Failed to load elements: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching elements: $e');
      rethrow;
    }
  }

  /// Public: fetch elements (exposed for caching/refresh use cases)
  Future<List<PeriodicElement>> fetchElements(String apiUrl) async {
    return _fetchElements(apiUrl);
  }

  /// Generates quiz questions from periodic elements
  List<QuizQuestion> _generateQuestionsFromElements({
    required List<PeriodicElement> elements,
    required QuizType type,
    required int count,
  }) {
    final random = Random();
    final questions = <QuizQuestion>[];
    final usedElements = <PeriodicElement>{};

    // Ensure we have enough elements for unique questions
    final availableElements = elements.where(_isValidElement).toList();
    if (availableElements.length < count) {
      throw Exception('Not enough valid elements for quiz generation');
    }

    for (int i = 0; i < count; i++) {
      PeriodicElement questionElement;

      // Find an unused element
      do {
        questionElement =
            availableElements[random.nextInt(availableElements.length)];
      } while (usedElements.contains(questionElement));

      usedElements.add(questionElement);

      final question = _createQuestionFromElement(
        element: questionElement,
        allElements: availableElements,
        type: type,
        questionId: 'q_${i + 1}',
      );

      questions.add(question);
    }

    return questions;
  }

  /// Generate a single question from a provided element pool (no network)
  QuizQuestion generateSingleQuestionFromElements({
    required List<PeriodicElement> elements,
    required QuizType type,
    required String questionId,
  }) {
    final valid = elements.where(_isValidElement).toList();
    final random = Random();
    final element = valid[random.nextInt(valid.length)];
    return _createQuestionFromElement(
      element: element,
      allElements: valid,
      type: type,
      questionId: questionId,
    );
  }

  /// Creates a quiz question from a periodic element
  QuizQuestion _createQuestionFromElement({
    required PeriodicElement element,
    required List<PeriodicElement> allElements,
    required QuizType type,
    required String questionId,
  }) {
    switch (type) {
      case QuizType.symbol:
        return _createSymbolQuestion(
          element: element,
          allElements: allElements,
          questionId: questionId,
        );
      case QuizType.group:
        return _createGroupQuestion(
          element: element,
          allElements: allElements,
          questionId: questionId,
        );
      case QuizType.number:
        return _createNumberQuestion(
          element: element,
          allElements: allElements,
          questionId: questionId,
        );
    }
  }

  /// Creates a symbol-based quiz question
  QuizQuestion _createSymbolQuestion({
    required PeriodicElement element,
    required List<PeriodicElement> allElements,
    required String questionId,
  }) {
    final correctAnswer = element.trName ?? element.enName ?? 'Unknown';
    final questionText = element.symbol ?? 'Unknown Symbol';

    final options = _generateOptions(
      correctAnswer: correctAnswer,
      allElements: allElements,
      extractValue: (e) => e.trName ?? e.enName ?? 'Unknown',
    );

    return QuizQuestion(
      id: questionId,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options,
      type: QuizType.symbol,
      additionalInfo: 'Atomic Number: ${element.number}',
    );
  }

  /// Creates a group-based quiz question
  QuizQuestion _createGroupQuestion({
    required PeriodicElement element,
    required List<PeriodicElement> allElements,
    required String questionId,
  }) {
    final correctAnswer = element.trCategory ?? element.enCategory ?? 'Unknown';
    final questionText = element.trName ?? element.enName ?? 'Unknown Element';

    final options = _generateOptions(
      correctAnswer: correctAnswer,
      allElements: allElements,
      extractValue: (e) => e.trCategory ?? e.enCategory ?? 'Unknown',
    );

    return QuizQuestion(
      id: questionId,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options,
      type: QuizType.group,
      additionalInfo: 'Symbol: ${element.symbol}',
    );
  }

  /// Creates a number-based quiz question
  QuizQuestion _createNumberQuestion({
    required PeriodicElement element,
    required List<PeriodicElement> allElements,
    required String questionId,
  }) {
    final correctAnswer = element.trName ?? element.enName ?? 'Unknown';
    final questionText = element.number?.toString() ?? 'Unknown Number';

    final options = _generateOptions(
      correctAnswer: correctAnswer,
      allElements: allElements,
      extractValue: (e) => e.trName ?? e.enName ?? 'Unknown',
    );

    return QuizQuestion(
      id: questionId,
      questionText: questionText,
      correctAnswer: correctAnswer,
      options: options,
      type: QuizType.number,
      additionalInfo: 'Atomic Number: ${element.number}',
    );
  }

  /// Generates answer options for a question
  List<String> _generateOptions({
    required String correctAnswer,
    required List<PeriodicElement> allElements,
    required String Function(PeriodicElement) extractValue,
  }) {
    final random = Random();
    final options = <String>{correctAnswer};

    // Generate wrong options
    while (options.length < _optionsPerQuestion) {
      final randomElement = allElements[random.nextInt(allElements.length)];
      final value = extractValue(randomElement);

      if (value != 'Unknown' && value != correctAnswer) {
        options.add(value);
      }
    }

    final optionsList = options.toList();
    optionsList.shuffle(random);
    return optionsList;
  }

  /// Validates if an element has required data for quiz generation
  bool _isValidElement(PeriodicElement element) {
    return element.symbol != null &&
        element.number != null &&
        (element.trName != null || element.enName != null) &&
        (element.trCategory != null || element.enCategory != null);
  }

  /// Validates an answer for a question
  bool validateAnswer(QuizQuestion question, String selectedAnswer) {
    return question.correctAnswer.toLowerCase() == selectedAnswer.toLowerCase();
  }

  /// Calculates score based on correct and total answers
  double calculateScore(int correctAnswers, int totalAnswers) {
    if (totalAnswers == 0) return 0.0;
    return (correctAnswers / totalAnswers) * 100;
  }

  /// Determines if a score is passing (above 70%)
  bool isPassingScore(double score) {
    return score >= 70.0;
  }

  /// Gets difficulty color based on quiz type
  String getDifficultyLevel(QuizType type) {
    switch (type) {
      case QuizType.symbol:
        return 'Easy';
      case QuizType.group:
        return 'Medium';
      case QuizType.number:
        return 'Hard';
    }
  }

  /// Creates a new quiz session
  QuizSession createQuizSession({
    required QuizType type,
    required List<QuizQuestion> questions,
    BuildContext? context,
  }) {
    // Determine max wrong answers based on premium status
    int maxWrongAnswers = 3; // Default for non-premium users

    if (context != null) {
      try {
        final purchaseProvider = context.read<PurchaseProvider>();
        if (purchaseProvider.isPremium) {
          maxWrongAnswers = 5; // Premium users get 5 lives
        }
      } catch (e) {
        // If context is not available or provider not found, use default
        debugPrint('⚠️ Could not check premium status: $e');
      }
    }

    return QuizSession(
      id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      questions: questions,
      maxWrongAnswers: maxWrongAnswers,
      startTime: DateTime.now(),
      state: QuizState.loaded,
    );
  }
}

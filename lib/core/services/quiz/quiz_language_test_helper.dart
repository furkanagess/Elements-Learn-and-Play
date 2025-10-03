import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/service/quiz/quiz_service.dart';
import 'package:elements_app/feature/model/quiz/quiz_models.dart';

/// Helper class to test quiz language functionality
class QuizLanguageTestHelper {
  static final QuizService _quizService = QuizService();

  /// Test quiz question generation in different languages
  static void testQuizLanguageGeneration() {
    print('=== Quiz Language Test Helper ===');

    // Create mock elements for testing
    final mockElements = <PeriodicElement>[
      PeriodicElement(
        number: 1,
        symbol: 'H',
        enName: 'Hydrogen',
        trName: 'Hidrojen',
        weight: '1.008',
        enCategory: 'Nonmetal',
        trCategory: 'Ametaller',
      ),
      PeriodicElement(
        number: 2,
        symbol: 'He',
        enName: 'Helium',
        trName: 'Helyum',
        weight: '4.003',
        enCategory: 'Noble Gas',
        trCategory: 'Soy Gazlar',
      ),
      PeriodicElement(
        number: 6,
        symbol: 'C',
        enName: 'Carbon',
        trName: 'Karbon',
        weight: '12.011',
        enCategory: 'Nonmetal',
        trCategory: 'Ametaller',
      ),
    ];

    // Test Turkish quiz generation
    print('\n--- Turkish Quiz Questions ---');
    _testQuizInLanguage(mockElements, true);

    // Test English quiz generation
    print('\n--- English Quiz Questions ---');
    _testQuizInLanguage(mockElements, false);

    print('\n=== End Test ===');
  }

  static void _testQuizInLanguage(
    List<PeriodicElement> elements,
    bool isTurkish,
  ) {
    final language = isTurkish ? 'Turkish' : 'English';
    print('Language: $language');

    // Test Symbol Quiz
    try {
      final symbolQuestion = _quizService.generateSingleQuestionFromElements(
        elements: elements,
        type: QuizType.symbol,
        questionId: 'test_symbol',
        isTurkish: isTurkish,
      );
      print('Symbol Quiz:');
      print('  Question: ${symbolQuestion.questionText}');
      print('  Correct Answer: ${symbolQuestion.correctAnswer}');
      print('  Options: ${symbolQuestion.options}');
    } catch (e) {
      print('Symbol Quiz Error: $e');
    }

    // Test Group Quiz
    try {
      final groupQuestion = _quizService.generateSingleQuestionFromElements(
        elements: elements,
        type: QuizType.group,
        questionId: 'test_group',
        isTurkish: isTurkish,
      );
      print('Group Quiz:');
      print('  Question: ${groupQuestion.questionText}');
      print('  Correct Answer: ${groupQuestion.correctAnswer}');
      print('  Options: ${groupQuestion.options}');
    } catch (e) {
      print('Group Quiz Error: $e');
    }

    // Test Number Quiz
    try {
      final numberQuestion = _quizService.generateSingleQuestionFromElements(
        elements: elements,
        type: QuizType.number,
        questionId: 'test_number',
        isTurkish: isTurkish,
      );
      print('Number Quiz:');
      print('  Question: ${numberQuestion.questionText}');
      print('  Correct Answer: ${numberQuestion.correctAnswer}');
      print('  Options: ${numberQuestion.options}');
    } catch (e) {
      print('Number Quiz Error: $e');
    }
  }

  /// Test language switching functionality
  static void testLanguageSwitching() {
    print('\n=== Language Switching Test ===');

    final mockElements = <PeriodicElement>[
      PeriodicElement(
        number: 26,
        symbol: 'Fe',
        enName: 'Iron',
        trName: 'Demir',
        weight: '55.845',
        enCategory: 'Transition Metal',
        trCategory: 'Geçiş Metaller',
      ),
    ];

    // Test same element in both languages
    final turkishQuestion = _quizService.generateSingleQuestionFromElements(
      elements: mockElements,
      type: QuizType.symbol,
      questionId: 'test_tr',
      isTurkish: true,
    );

    final englishQuestion = _quizService.generateSingleQuestionFromElements(
      elements: mockElements,
      type: QuizType.symbol,
      questionId: 'test_en',
      isTurkish: false,
    );

    print('Same element (Fe) in different languages:');
    print('Turkish - Correct Answer: ${turkishQuestion.correctAnswer}');
    print('English - Correct Answer: ${englishQuestion.correctAnswer}');
    print(
      'Answers are different: ${turkishQuestion.correctAnswer != englishQuestion.correctAnswer}',
    );
  }
}

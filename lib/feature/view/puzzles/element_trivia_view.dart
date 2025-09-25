import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elements_app/feature/provider/trivia_provider.dart';
import 'package:elements_app/feature/provider/purchase_provider.dart';
import 'package:elements_app/product/widget/scaffold/app_scaffold.dart';
import 'package:elements_app/product/constants/app_colors.dart';
import 'package:elements_app/feature/provider/localization_provider.dart';
import 'package:elements_app/core/services/pattern/pattern_service.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/service/periodicTable/periodic_table_service.dart';
import 'package:elements_app/feature/service/api_service.dart';
import 'package:elements_app/product/widget/ads/interstitial_ad_widget.dart';
import 'package:elements_app/product/ads/rewarded_helper.dart';
import 'package:elements_app/feature/view/tests/tests_home_view.dart';
import 'package:elements_app/feature/view/trivia/trivia_achievements_view.dart';
import 'package:elements_app/product/widget/common/modern_game_result_dialog.dart';

class ElementTriviaView extends StatefulWidget {
  final List<int>?
  allowedTypes; // 0:category,1:weight,2:period,3:desc,4:usage,5:source
  final bool first20Only;

  const ElementTriviaView({
    super.key,
    this.allowedTypes,
    this.first20Only = false,
  });

  @override
  State<ElementTriviaView> createState() => _ElementTriviaViewState();
}

class _ElementTriviaViewState extends State<ElementTriviaView>
    with TickerProviderStateMixin {
  final PatternService _pattern = PatternService();
  final PeriodicTableService _tableService = PeriodicTableService(ApiService());
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _feedbackController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _feedbackAnimation;

  bool _showFeedback = false;
  bool _isCorrect = false;
  String _feedbackTitle = '';
  String _feedbackSubtitle = '';
  bool _isLoading = true;
  int? _selectedAnswerIndex;

  int _questionIndex = 0;
  int _correct = 0;
  int _wrong = 0;
  bool _hasShownResult = false;
  bool _hasExtraLife = false;

  /// Get max wrong answers based on premium status
  int get maxWrongAnswers {
    try {
      final purchaseProvider = context.read<PurchaseProvider>();
      return purchaseProvider.isPremium ? 5 : 3;
    } catch (e) {
      return 3; // Default for non-premium users
    }
  }

  final List<_TriviaQuestion> _questions = [];
  List<PeriodicElement> _allElements = [];

  // Trivia statistics storage
  static const String _triviaStatsKey = 'trivia_statistics';
  late SharedPreferences _prefs;
  int _totalGamesPlayed = 0;
  int _totalWins = 0;
  int _totalCorrectAnswers = 0;
  int _totalWrongAnswers = 0;
  Duration _totalTimePlayed = Duration.zero;
  Duration _bestTime = Duration.zero;
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _gameStartTime;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
    _feedbackAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTriviaStats();
      _loadElementsAndGenerateQuestions();
      _gameStartTime = DateTime.now();
    });
  }

  Future<void> _initTriviaStats() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTriviaStats();
  }

  void _loadTriviaStats() {
    final String? statsJson = _prefs.getString(_triviaStatsKey);
    if (statsJson != null) {
      try {
        final Map<String, dynamic> stats = jsonDecode(statsJson);
        _totalGamesPlayed = stats['totalGamesPlayed'] ?? 0;
        _totalWins = stats['totalWins'] ?? 0;
        _totalCorrectAnswers = stats['totalCorrectAnswers'] ?? 0;
        _totalWrongAnswers = stats['totalWrongAnswers'] ?? 0;
        _totalTimePlayed = Duration(seconds: stats['totalTimePlayed'] ?? 0);
        _bestTime = Duration(seconds: stats['bestTime'] ?? 0);
        _currentStreak = stats['currentStreak'] ?? 0;
        _longestStreak = stats['longestStreak'] ?? 0;
      } catch (e) {
        debugPrint('❌ Error loading trivia stats: $e');
      }
    }
  }

  Future<void> _saveTriviaStats() async {
    try {
      final stats = {
        'totalGamesPlayed': _totalGamesPlayed,
        'totalWins': _totalWins,
        'totalCorrectAnswers': _totalCorrectAnswers,
        'totalWrongAnswers': _totalWrongAnswers,
        'totalTimePlayed': _totalTimePlayed.inSeconds,
        'bestTime': _bestTime.inSeconds,
        'currentStreak': _currentStreak,
        'longestStreak': _longestStreak,
      };
      await _prefs.setString(_triviaStatsKey, jsonEncode(stats));
    } catch (e) {
      debugPrint('❌ Error saving trivia stats: $e');
    }
  }

  void _updateTriviaStats({required bool isWin, required Duration gameTime}) {
    _totalGamesPlayed++;
    if (isWin) {
      _totalWins++;
      _currentStreak++;
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }
    _totalCorrectAnswers += _correct;
    _totalWrongAnswers += _wrong;
    _totalTimePlayed += gameTime;
    if (_bestTime == Duration.zero || gameTime < _bestTime) {
      _bestTime = gameTime;
    }
    _saveTriviaStats();
  }

  /// Clears all trivia statistics
  void clearTriviaStats() {
    _totalGamesPlayed = 0;
    _totalWins = 0;
    _totalCorrectAnswers = 0;
    _totalWrongAnswers = 0;
    _totalTimePlayed = Duration.zero;
    _bestTime = Duration.zero;
    _currentStreak = 0;
    _longestStreak = 0;
    _prefs.remove(_triviaStatsKey);
    debugPrint('🗑️ Trivia statistics cleared');
  }

  Future<void> _loadElementsAndGenerateQuestions() async {
    try {
      _allElements = await _tableService.getElements();
      if (widget.first20Only) {
        _allElements = _allElements.take(20).toList();
      }
      _generateRandomQuestions();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Fallback to static questions if loading fails
      _seedQuestions();
    }
  }

  void _generateRandomQuestions() {
    final isTr = context.read<LocalizationProvider>().isTr;
    final random = math.Random();
    _questions.clear();

    // Filter elements with valid data
    final validElements = _allElements
        .where(
          (element) =>
              element.number != null &&
              element.symbol != null &&
              (isTr ? element.trName != null : element.enName != null),
        )
        .toList();

    if (validElements.isEmpty) {
      _seedQuestions();
      return;
    }

    // Determine which question types are allowed
    final availableTypes =
        (widget.allowedTypes == null || widget.allowedTypes!.isEmpty)
        ? List<int>.generate(6, (i) => i)
        : widget.allowedTypes!.where((i) => i >= 0 && i <= 5).toList();

    // Generate 10 random questions
    for (int i = 0; i < 10; i++) {
      final questionType =
          availableTypes[random.nextInt(availableTypes.length)];
      _TriviaQuestion? question;

      switch (questionType) {
        case 0:
          question = _generateCategoryQuestion(validElements, isTr, random);
          break;
        case 1:
          question = _generateWeightQuestion(validElements, isTr, random);
          break;
        case 2:
          question = _generatePeriodQuestion(validElements, isTr, random);
          break;
        case 3:
          question = _generateDescriptionQuestion(validElements, isTr, random);
          break;
        case 4:
          question = _generateUsageQuestion(validElements, isTr, random);
          break;
        case 5:
          question = _generateSourceQuestion(validElements, isTr, random);
          break;
      }

      if (question != null) {
        _questions.add(question);
      }
    }

    // If we couldn't generate enough questions, fill with static ones
    while (_questions.length < 10) {
      _questions.add(_generateFallbackQuestion(isTr, _questions.length));
    }
  }

  _TriviaQuestion _generateCategoryQuestion(
    List<PeriodicElement> elements,
    bool isTr,
    math.Random random,
  ) {
    final element = elements[random.nextInt(elements.length)];
    final correctAnswer = isTr
        ? element.trCategory ?? element.enCategory ?? ''
        : element.enCategory ?? '';
    if (correctAnswer.isEmpty) return _generateFallbackQuestion(isTr, 0);

    final wrongAnswers = <String>[];
    final categories = elements
        .map((e) => isTr ? e.trCategory ?? e.enCategory : e.enCategory)
        .where((c) => c != null && c != correctAnswer)
        .toSet();

    // Generate wrong answers
    while (wrongAnswers.length < 3 && categories.isNotEmpty) {
      final wrongCategory = categories.elementAt(
        random.nextInt(categories.length),
      );
      if (wrongCategory != correctAnswer &&
          !wrongAnswers.contains(wrongCategory)) {
        wrongAnswers.add(wrongCategory!);
      }
    }

    if (wrongAnswers.length < 3) return _generateFallbackQuestion(isTr, 0);

    final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
    final answerIndex = allOptions.indexOf(correctAnswer);

    return _TriviaQuestion(
      question: isTr
          ? '${isTr ? element.trName : element.enName} elementi hangi kategoride yer alır?'
          : 'Which category does ${isTr ? element.trName : element.enName} belong to?',
      options: allOptions,
      answerIndex: answerIndex,
      category: isTr ? 'Sınıflandırma' : 'Classification',
    );
  }

  _TriviaQuestion _generateWeightQuestion(
    List<PeriodicElement> elements,
    bool isTr,
    math.Random random,
  ) {
    final element = elements
        .where((e) => e.weight != null && e.weight!.isNotEmpty)
        .toList();
    if (element.isEmpty) return _generateFallbackQuestion(isTr, 0);

    final selectedElement = element[random.nextInt(element.length)];
    final correctAnswer = selectedElement.weight!;
    final wrongAnswers = <String>[];

    // Generate wrong answers
    while (wrongAnswers.length < 3) {
      final wrongElement = element[random.nextInt(element.length)];
      if (wrongElement.weight != correctAnswer &&
          !wrongAnswers.contains(wrongElement.weight)) {
        wrongAnswers.add(wrongElement.weight!);
      }
    }

    final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
    final answerIndex = allOptions.indexOf(correctAnswer);

    return _TriviaQuestion(
      question: isTr
          ? '${isTr ? selectedElement.trName : selectedElement.enName} elementinin atom ağırlığı nedir?'
          : 'What is the atomic weight of ${isTr ? selectedElement.trName : selectedElement.enName}?',
      options: allOptions,
      answerIndex: answerIndex,
      category: isTr ? 'Özellikler' : 'Properties',
    );
  }

  _TriviaQuestion _generatePeriodQuestion(
    List<PeriodicElement> elements,
    bool isTr,
    math.Random random,
  ) {
    final element = elements
        .where((e) => e.period != null && e.period!.isNotEmpty)
        .toList();
    if (element.isEmpty) return _generateFallbackQuestion(isTr, 0);

    final selectedElement = element[random.nextInt(element.length)];
    final correctAnswer = selectedElement.period!;
    final wrongAnswers = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
    ].where((p) => p != correctAnswer).take(3).toList();

    final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
    final answerIndex = allOptions.indexOf(correctAnswer);

    return _TriviaQuestion(
      question: isTr
          ? '${isTr ? selectedElement.trName : selectedElement.enName} elementi hangi periyotta yer alır?'
          : 'Which period does ${isTr ? selectedElement.trName : selectedElement.enName} belong to?',
      options: allOptions,
      answerIndex: answerIndex,
      category: isTr ? 'Sınıflandırma' : 'Classification',
    );
  }

  _TriviaQuestion _generateDescriptionQuestion(
    List<PeriodicElement> elements,
    bool isTr,
    math.Random random,
  ) {
    final element = elements
        .where(
          (e) =>
              (isTr ? e.trDescription : e.enDescription) != null &&
              (isTr ? e.trDescription : e.enDescription)!.isNotEmpty &&
              (isTr ? e.trDescription : e.enDescription)!.length > 20,
        )
        .toList();
    if (element.isEmpty) return _generateFallbackQuestion(isTr, 0);

    final selectedElement = element[random.nextInt(element.length)];
    final description = isTr
        ? selectedElement.trDescription!
        : selectedElement.enDescription!;
    final correctAnswer = isTr
        ? selectedElement.trName!
        : selectedElement.enName!;
    final wrongAnswers = <String>[];

    // Generate wrong answers from other elements
    while (wrongAnswers.length < 3) {
      final wrongElement = elements[random.nextInt(elements.length)];
      final wrongName = isTr ? wrongElement.trName : wrongElement.enName;
      if (wrongName != null &&
          wrongName != correctAnswer &&
          !wrongAnswers.contains(wrongName)) {
        wrongAnswers.add(wrongName);
      }
    }

    final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
    final answerIndex = allOptions.indexOf(correctAnswer);

    // Truncate description if too long
    final isTruncated = description.length > 100;
    final truncatedDescription = isTruncated
        ? '${description.substring(0, 100)}...'
        : description;

    return _TriviaQuestion(
      question: isTr
          ? 'Bu açıklama hangi elemente aittir?\n\n"$truncatedDescription"'
          : 'Which element does this description belong to?\n\n"$truncatedDescription"',
      options: allOptions,
      answerIndex: answerIndex,
      category: isTr ? 'Açıklama' : 'Description',
      fullContent: isTruncated ? description : null,
      contentType: 'description',
    );
  }

  _TriviaQuestion _generateUsageQuestion(
    List<PeriodicElement> elements,
    bool isTr,
    math.Random random,
  ) {
    final element = elements
        .where(
          (e) =>
              (isTr ? e.trUsage : e.enUsage) != null &&
              (isTr ? e.trUsage : e.enUsage)!.isNotEmpty &&
              (isTr ? e.trUsage : e.enUsage)!.length > 15,
        )
        .toList();
    if (element.isEmpty) return _generateFallbackQuestion(isTr, 0);

    final selectedElement = element[random.nextInt(element.length)];
    final usage = isTr ? selectedElement.trUsage! : selectedElement.enUsage!;
    final correctAnswer = isTr
        ? selectedElement.trName!
        : selectedElement.enName!;
    final wrongAnswers = <String>[];

    // Generate wrong answers from other elements
    while (wrongAnswers.length < 3) {
      final wrongElement = elements[random.nextInt(elements.length)];
      final wrongName = isTr ? wrongElement.trName : wrongElement.enName;
      if (wrongName != null &&
          wrongName != correctAnswer &&
          !wrongAnswers.contains(wrongName)) {
        wrongAnswers.add(wrongName);
      }
    }

    final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
    final answerIndex = allOptions.indexOf(correctAnswer);

    // Truncate usage if too long
    final isTruncated = usage.length > 80;
    final truncatedUsage = isTruncated ? '${usage.substring(0, 80)}...' : usage;

    return _TriviaQuestion(
      question: isTr
          ? 'Bu kullanım alanı hangi elemente aittir?\n\n"$truncatedUsage"'
          : 'Which element has this usage?\n\n"$truncatedUsage"',
      options: allOptions,
      answerIndex: answerIndex,
      category: isTr ? 'Kullanım Alanları' : 'Uses',
      fullContent: isTruncated ? usage : null,
      contentType: 'usage',
    );
  }

  _TriviaQuestion _generateSourceQuestion(
    List<PeriodicElement> elements,
    bool isTr,
    math.Random random,
  ) {
    final element = elements
        .where(
          (e) =>
              (isTr ? e.trSource : e.enSource) != null &&
              (isTr ? e.trSource : e.enSource)!.isNotEmpty &&
              (isTr ? e.trSource : e.enSource)!.length > 15,
        )
        .toList();
    if (element.isEmpty) return _generateFallbackQuestion(isTr, 0);

    final selectedElement = element[random.nextInt(element.length)];
    final source = isTr ? selectedElement.trSource! : selectedElement.enSource!;
    final correctAnswer = isTr
        ? selectedElement.trName!
        : selectedElement.enName!;
    final wrongAnswers = <String>[];

    // Generate wrong answers from other elements
    while (wrongAnswers.length < 3) {
      final wrongElement = elements[random.nextInt(elements.length)];
      final wrongName = isTr ? wrongElement.trName : wrongElement.enName;
      if (wrongName != null &&
          wrongName != correctAnswer &&
          !wrongAnswers.contains(wrongName)) {
        wrongAnswers.add(wrongName);
      }
    }

    final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
    final answerIndex = allOptions.indexOf(correctAnswer);

    // Truncate source if too long
    final isTruncated = source.length > 80;
    final truncatedSource = isTruncated
        ? '${source.substring(0, 80)}...'
        : source;

    return _TriviaQuestion(
      question: isTr
          ? 'Bu kaynak bilgisi hangi elemente aittir?\n\n"$truncatedSource"'
          : 'Which element has this source information?\n\n"$truncatedSource"',
      options: allOptions,
      answerIndex: answerIndex,
      category: isTr ? 'Kaynaklar' : 'Sources',
      fullContent: isTruncated ? source : null,
      contentType: 'source',
    );
  }

  _TriviaQuestion _generateFallbackQuestion(bool isTr, int index) {
    final fallbackQuestions = [
      _TriviaQuestion(
        question: isTr
            ? 'Hidrojen hangi kategoride yer alır?'
            : 'Which category does Hydrogen belong to?',
        options: isTr
            ? ['Reaktif ametal', 'Alkali metal', 'Halojen', 'Soy gaz']
            : ['Reactive nonmetal', 'Alkali metal', 'Halogen', 'Noble gas'],
        answerIndex: 0,
        category: isTr ? 'Sınıflandırma' : 'Classification',
      ),
      _TriviaQuestion(
        question: isTr
            ? 'Karbon elementinin atom ağırlığı nedir?'
            : 'What is the atomic weight of Carbon?',
        options: ['12.011', '14.007', '15.999', '18.998'],
        answerIndex: 0,
        category: isTr ? 'Özellikler' : 'Properties',
      ),
    ];
    return fallbackQuestions[index % fallbackQuestions.length];
  }

  void _seedQuestions() {
    final isTr = context.read<LocalizationProvider>().isTr;
    _questions.clear();
    _questions.addAll([
      _TriviaQuestion(
        question: isTr
            ? 'Hidrojen hangi kategoride yer alır?'
            : 'Which category does Hydrogen belong to?',
        options: isTr
            ? ['Reaktif ametal', 'Alkali metal', 'Halojen', 'Soy gaz']
            : ['Reactive nonmetal', 'Alkali metal', 'Halogen', 'Noble gas'],
        answerIndex: 0,
        category: isTr ? 'Sınıflandırma' : 'Classification',
      ),
      _TriviaQuestion(
        question: isTr
            ? 'Saf halde oda sıcaklığında sıvı olan element hangisidir?'
            : 'Which element is liquid at room temperature in pure form?',
        options: isTr
            ? ['Cıva', 'Demir', 'Gümüş', 'Helyum']
            : ['Mercury', 'Iron', 'Silver', 'Helium'],
        answerIndex: 0,
        category: isTr ? 'Kullanım Alanları' : 'Uses',
      ),
      _TriviaQuestion(
        question: isTr
            ? 'Karbon elementinin atom ağırlığı nedir?'
            : 'What is the atomic weight of Carbon?',
        options: ['12.011', '14.007', '15.999', '18.998'],
        answerIndex: 0,
        category: isTr ? 'Özellikler' : 'Properties',
      ),
      _TriviaQuestion(
        question: isTr
            ? 'Elmas hangi elementin kristal formudur?'
            : 'Diamond is a crystalline form of which element?',
        options: isTr
            ? ['Karbon', 'Kalsiyum', 'Kükürt', 'Fosfor']
            : ['Carbon', 'Calcium', 'Sulfur', 'Phosphorus'],
        answerIndex: 0,
        category: isTr ? 'Detaylar' : 'Details',
      ),
    ]);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _onAnswer(int selected) {
    if (_showFeedback) return;
    final isTr = context.read<LocalizationProvider>().isTr;
    final current = _questions[_questionIndex];
    final ok = selected == current.answerIndex;
    setState(() {
      _selectedAnswerIndex = selected;
      _showFeedback = true;
      _isCorrect = ok;
      if (ok) {
        _correct += 1;
        _feedbackTitle = isTr ? 'Doğru!' : 'Correct!';
        _feedbackSubtitle = isTr ? 'Harika iş çıkardın.' : 'Great job!';
      } else {
        _wrong += 1;
        _feedbackTitle = isTr ? 'Yanlış!' : 'Wrong!';
        _feedbackSubtitle = isTr
            ? 'Doğru cevap: ${current.options[current.answerIndex]}'
            : 'Correct answer: ${current.options[current.answerIndex]}';
      }
    });

    _feedbackController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      await _feedbackController.reverse();
      if (!mounted) return;
      // Decide next step: fail, next question, or completed
      if (_wrong >= maxWrongAnswers) {
        _showEndDialog(success: false);
        return;
      }
      if (_questionIndex < _questions.length - 1) {
        setState(() {
          _showFeedback = false;
          _selectedAnswerIndex = null;
          _questionIndex += 1;
        });
      } else {
        _showEndDialog(success: true);
      }
    });
  }

  Future<void> _showEndDialog({required bool success}) async {
    if (_hasShownResult) return;
    _hasShownResult = true;

    if (!mounted) return;
    final isTr = context.read<LocalizationProvider>().isTr;

    // Update statistics
    final gameTime = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!)
        : Duration.zero;
    _updateTriviaStats(isWin: success, gameTime: gameTime);
    // Update central provider as the single source of truth (overall + per-category)
    if (mounted) {
      context.read<TriviaProvider>().updateAfterGame(
        isWin: success,
        correct: _correct,
        wrong: _wrong,
        gameTime: gameTime,
        category: _resolveCategoryForRun(),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ModernGameResultDialog(
          success: success,
          title: success
              ? (isTr ? '🎉 Tamamlandı!' : '🎉 Completed!')
              : (isTr ? 'Tekrar Dene!' : 'Try Again!'),
          subtitle: success
              ? (isTr ? 'Harika iş çıkardın!' : 'Great job!')
              : (isTr ? 'Daha iyisini yapabilirsin!' : 'You can do better!'),
          correct: _correct,
          wrong: _wrong,
          gameTime: gameTime,
          showExtraLifeOption: !success && !_hasExtraLife,
          watchAdText: isTr ? 'Reklam İzle - Ek Can' : 'Watch Ad - Extra Life',
          onWatchAdForExtraLife: () async {
            Navigator.of(context).pop();
            final rewardEarned = await RewardedHelper.showRewardedAd(
              context: context,
            );
            if (rewardEarned && mounted) {
              setState(() {
                _hasExtraLife = true;
                _wrong = 0; // Reset wrong answers
              });
              // Continue from current question
              _continueWithExtraLife();
            } else if (mounted) {
              // Ad failed or user didn't earn reward, show failure dialog again
              _showEndDialog(success: false);
            }
          },
          onPlayAgain: () async {
            Navigator.of(context).pop();
            await _maybeShowAchievementsCongrats(_resolveCategoryForRun());
            // Show ad after dialog is closed
            await Future.delayed(const Duration(milliseconds: 500));
            await InterstitialAdManager.instance.showAdOnAction(context);
            _resetGame();
          },
          onHome: () async {
            Navigator.of(context).pop();
            await _maybeShowAchievementsCongrats(_resolveCategoryForRun());
            // Show ad after dialog is closed
            await Future.delayed(const Duration(milliseconds: 500));
            await InterstitialAdManager.instance.showAdOnAction(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => TestsHomeView()),
              (route) => false,
            );
          },
          playAgainText: isTr ? 'Tekrar Oyna' : 'Play Again',
          homeText: isTr ? 'Ana Sayfa' : 'Home',
          successIcon: Icons.emoji_events_rounded,
          failureIcon: Icons.refresh_rounded,
        );
      },
    );

    // Allow showing dialog again in the next session
    _hasShownResult = false;
  }

  void _resetGame() {
    setState(() {
      _questionIndex = 0;
      _correct = 0;
      _wrong = 0;
      _showFeedback = false;
      _selectedAnswerIndex = null;
      _hasShownResult = false;
      _hasExtraLife = false;
      _gameStartTime = DateTime.now();
      _generateRandomQuestions();
    });
  }

  Future<void> _maybeShowAchievementsCongrats(TriviaCategory category) async {
    final newlyEarned = context
        .read<TriviaProvider>()
        .consumeLastEarnedBadges();
    if (newlyEarned.isEmpty) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _TriviaAchievementCongratsDialog(
        badges: newlyEarned,
        category: category,
        onHome: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => TestsHomeView()),
            (route) => false,
          );
        },
      ),
    );
  }

  void _continueWithExtraLife() {
    setState(() {
      _showFeedback = false;
      _selectedAnswerIndex = null;
      _hasShownResult = false;
    });
  }

  TriviaCategory _resolveCategoryForRun() {
    final allowed = widget.allowedTypes ?? [];
    if (allowed.length == 1) {
      switch (allowed.first) {
        case 0:
          return TriviaCategory.classification;
        case 1:
          return TriviaCategory.weight;
        case 2:
          return TriviaCategory.period;
        case 3:
          return TriviaCategory.description;
        case 4:
          return TriviaCategory.usage;
        case 5:
          return TriviaCategory.source;
      }
    }
    return TriviaCategory.mixed;
  }

  Future<void> _handleExit(BuildContext context) async {
    final isTr = context.read<LocalizationProvider>().isTr;
    final hasActive = _questions.isNotEmpty && (_wrong < maxWrongAnswers);
    if (hasActive) {
      final confirm =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.darkBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isTr ? 'Element Trivia\'dan Çık' : 'Exit Element Trivia',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                isTr
                    ? 'Şimdi çıkarsanız ilerlemeniz kaybolacak. Emin misiniz?'
                    : 'If you exit now, your progress will be lost. Are you sure?',
                style: TextStyle(color: AppColors.white.withValues(alpha: 0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    isTr ? 'İptal' : 'Cancel',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
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
          ) ??
          false;
      if (!confirm) return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions.isEmpty ? null : _questions[_questionIndex];
    return AppScaffold(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _pattern.getPatternPainter(
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
                    Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      child: _TriviaHeader(
                        onClose: () => _handleExit(context),
                        correct: _correct,
                        wrong: _wrong,
                        index: _questionIndex,
                        total: _questions.length,
                        remainingLives: (maxWrongAnswers - _wrong).clamp(
                          0,
                          maxWrongAnswers,
                        ),
                        maxLives: maxWrongAnswers,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: _isLoading || current == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                              ),
                            )
                          : _TriviaContent(
                              question: current,
                              onAnswer: _onAnswer,
                              showFeedback: _showFeedback,
                              isCorrect: _isCorrect,
                              feedbackTitle: _feedbackTitle,
                              feedbackSubtitle: _feedbackSubtitle,
                              feedbackAnimation: _feedbackAnimation,
                              selectedAnswerIndex: _selectedAnswerIndex,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriviaHeader extends StatelessWidget {
  final VoidCallback? onClose;
  final int correct;
  final int wrong;
  final int index;
  final int total;
  final int remainingLives;
  final int maxLives;

  const _TriviaHeader({
    this.onClose,
    required this.correct,
    required this.wrong,
    required this.index,
    required this.total,
    required this.remainingLives,
    required this.maxLives,
  });

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final progress = total == 0 ? 0.0 : index / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.purple, AppColors.purple.withValues(alpha: 0.8)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    isTr ? 'Element Trivia' : 'Element Trivia',
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
                    color: AppColors.turquoise.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.question_answer,
                        color: AppColors.turquoise,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isTr ? 'Bilgi' : 'Trivia',
                        style: const TextStyle(
                          color: AppColors.turquoise,
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
            Row(
              children: [
                SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${index + 1}/$total',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '%${(progress * 100).toInt()}',
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
                          value: progress.clamp(0, 1),
                          backgroundColor: AppColors.white.withValues(
                            alpha: 0.2,
                          ),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.turquoise,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    _compactStat(
                      Icons.check_circle,
                      correct.toString(),
                      AppColors.glowGreen,
                    ),
                    const SizedBox(width: 6),
                    _compactStat(
                      Icons.cancel,
                      wrong.toString(),
                      AppColors.powderRed,
                    ),
                    const SizedBox(width: 6),
                    _compactStat(
                      Icons.favorite,
                      remainingLives.toString(),
                      AppColors.pink,
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

  Widget _compactStat(IconData icon, String value, Color color) {
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
}

class _TriviaContent extends StatelessWidget {
  final _TriviaQuestion question;
  final void Function(int index) onAnswer;
  final bool showFeedback;
  final bool isCorrect;
  final String feedbackTitle;
  final String feedbackSubtitle;
  final Animation<double> feedbackAnimation;
  final int? selectedAnswerIndex;

  const _TriviaContent({
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
    required this.isCorrect,
    required this.feedbackTitle,
    required this.feedbackSubtitle,
    required this.feedbackAnimation,
    this.selectedAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: _buildInfoCard(context, question.category),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = math.min(constraints.maxWidth, 520.0);
                return Column(
                  children: [
                    SizedBox(
                      width: maxWidth,
                      child: _QuestionCard(
                        text: question.question,
                        fullContent: question.fullContent,
                        contentType: question.contentType,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: maxWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(question.options.length, (i) {
                          return _OptionCard(
                            label: question.options[i],
                            index: i,
                            onTap: () => onAnswer(i),
                            isSelected: selectedAnswerIndex == i,
                            isCorrect:
                                showFeedback && i == question.answerIndex,
                            isWrong:
                                showFeedback &&
                                selectedAnswerIndex == i &&
                                i != question.answerIndex,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.08),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: showFeedback
                          ? _FeedbackCard(
                              isCorrect: isCorrect,
                              title: feedbackTitle,
                              subtitle: feedbackSubtitle,
                              animation: feedbackAnimation,
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String category) {
    final isTr = context.read<LocalizationProvider>().isTr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue.withValues(alpha: 0.8),
            AppColors.darkBlue.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.turquoise.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.turquoise.withValues(alpha: 0.12),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.turquoise.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.turquoise.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.touch_app,
              color: AppColors.turquoise,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isTr ? 'Kategori: $category' : 'Category: $category',
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String text;
  final String? fullContent;
  final String? contentType;
  const _QuestionCard({required this.text, this.fullContent, this.contentType});

  @override
  Widget build(BuildContext context) {
    final isTr = context.read<LocalizationProvider>().isTr;
    final hasFullContent = fullContent != null && fullContent!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue.withValues(alpha: 0.7),
            AppColors.darkBlue.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFullContent) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.turquoise.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.turquoise.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showFullContentDialog(
                    context,
                    fullContent!,
                    contentType!,
                    isTr,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen,
                          color: AppColors.turquoise,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTr ? 'Tamamını Göster' : 'Show Full',
                          style: TextStyle(
                            color: AppColors.turquoise,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFullContentDialog(
    BuildContext context,
    String content,
    String type,
    bool isTr,
  ) {
    String title;
    switch (type) {
      case 'description':
        title = isTr ? 'Tam Açıklama' : 'Full Description';
        break;
      case 'usage':
        title = isTr ? 'Tam Kullanım Alanları' : 'Full Usage';
        break;
      case 'source':
        title = isTr ? 'Tam Kaynak Bilgisi' : 'Full Source Information';
        break;
      default:
        title = isTr ? 'Tam İçerik' : 'Full Content';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkBlue.withValues(alpha: 0.95),
                AppColors.darkBlue.withValues(alpha: 0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.turquoise.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withValues(alpha: 0.4),
                offset: const Offset(0, 12),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.turquoise,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  content,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.turquoise,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    isTr ? 'Kapat' : 'Close',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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
}

class _OptionCard extends StatelessWidget {
  final String label;
  final int index;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;

  const _OptionCard({
    required this.label,
    required this.index,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    List<Color> gradientColors;
    Color letterBgColor;
    Color letterBorderColor;
    IconData? trailingIcon;
    Color? trailingIconColor;

    if (isCorrect) {
      // Correct answer - green
      borderColor = AppColors.glowGreen;
      gradientColors = [
        AppColors.glowGreen.withValues(alpha: 0.3),
        AppColors.glowGreen.withValues(alpha: 0.2),
      ];
      letterBgColor = AppColors.glowGreen.withValues(alpha: 0.4);
      letterBorderColor = AppColors.glowGreen;
      trailingIcon = Icons.check_circle;
      trailingIconColor = AppColors.glowGreen;
    } else if (isWrong) {
      // Wrong answer - red
      borderColor = AppColors.powderRed;
      gradientColors = [
        AppColors.powderRed.withValues(alpha: 0.3),
        AppColors.powderRed.withValues(alpha: 0.2),
      ];
      letterBgColor = AppColors.powderRed.withValues(alpha: 0.4);
      letterBorderColor = AppColors.powderRed;
      trailingIcon = Icons.cancel;
      trailingIconColor = AppColors.powderRed;
    } else if (isSelected) {
      // Selected but not yet evaluated - turquoise
      borderColor = AppColors.turquoise;
      gradientColors = [
        AppColors.turquoise.withValues(alpha: 0.3),
        AppColors.turquoise.withValues(alpha: 0.2),
      ];
      letterBgColor = AppColors.turquoise.withValues(alpha: 0.4);
      letterBorderColor = AppColors.turquoise;
      trailingIcon = Icons.radio_button_checked;
      trailingIconColor = AppColors.turquoise;
    } else {
      // Default state
      borderColor = Colors.white.withValues(alpha: 0.25);
      gradientColors = [
        AppColors.darkBlue.withValues(alpha: 0.55),
        AppColors.darkBlue.withValues(alpha: 0.4),
      ];
      letterBgColor = AppColors.white.withValues(alpha: 0.18);
      letterBorderColor = Colors.white.withValues(alpha: 0.28);
      trailingIcon = Icons.chevron_right;
      trailingIconColor = AppColors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected || isCorrect || isWrong ? 2.0 : 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isSelected || isCorrect || isWrong
                              ? borderColor
                              : Colors.black)
                          .withValues(alpha: 0.15),
                  blurRadius: isSelected || isCorrect || isWrong ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: letterBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: letterBorderColor, width: 1),
                  ),
                  child: Text(
                    String.fromCharCode('A'.codeUnitAt(0) + index),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(trailingIcon, color: trailingIconColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String title;
  final String subtitle;
  final Animation<double> animation;

  const _FeedbackCard({
    required this.isCorrect,
    required this.title,
    required this.subtitle,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isCorrect ? AppColors.glowGreen : AppColors.powderRed;
    final secondary = isCorrect ? AppColors.turquoise : AppColors.pink;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: 0.9),
              secondary.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primary.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: AppColors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriviaQuestion {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String category;
  final String? fullContent;
  final String? contentType;

  const _TriviaQuestion({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.category,
    this.fullContent,
    this.contentType,
  });
}

class _TriviaAchievementCongratsDialog extends StatelessWidget {
  final List<TriviaBadge> badges;
  final TriviaCategory category;
  final VoidCallback? onHome;

  const _TriviaAchievementCongratsDialog({
    required this.badges,
    required this.category,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<LocalizationProvider>().isTr;
    final colors = _getCategoryColors(category);

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
                          builder: (_) => const TriviaAchievementsView(),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
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

  Widget _buildBadgeRow(TriviaBadge badge, bool isTr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTr ? badge.titleTr : badge.titleEn,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isTr ? badge.descriptionTr : badge.descriptionEn,
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

  ({Color primary, Color secondary}) _getCategoryColors(
    TriviaCategory category,
  ) {
    switch (category) {
      case TriviaCategory.classification:
        return (primary: AppColors.glowGreen, secondary: AppColors.steelBlue);
      case TriviaCategory.weight:
        return (primary: AppColors.steelBlue, secondary: AppColors.glowGreen);
      case TriviaCategory.period:
        return (primary: AppColors.glowGreen, secondary: AppColors.steelBlue);
      case TriviaCategory.description:
        return (primary: AppColors.steelBlue, secondary: AppColors.glowGreen);
      case TriviaCategory.usage:
        return (primary: AppColors.glowGreen, secondary: AppColors.steelBlue);
      case TriviaCategory.source:
        return (primary: AppColors.steelBlue, secondary: AppColors.glowGreen);
      case TriviaCategory.mixed:
        return (primary: AppColors.glowGreen, secondary: AppColors.steelBlue);
    }
  }
}

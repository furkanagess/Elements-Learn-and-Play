import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elements_app/feature/model/puzzle/puzzle_models.dart';
import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/service/periodicTable/periodic_table_service.dart';
import 'package:elements_app/feature/service/api_service.dart';

enum PuzzleRoundStatus { playing, success, failure }

class PuzzleProvider extends ChangeNotifier {
  final String _progressKey = 'puzzle_progress_v1';
  late SharedPreferences _prefs;

  final PeriodicTableService _tableService = PeriodicTableService(ApiService());
  final Map<PuzzleType, PuzzleProgress> _progress = {};

  // Matching puzzle state
  MatchingRound? _currentMatchingRound;
  bool _matchingSessionActive = false;
  bool _matchingSessionCompleted = false;
  bool _matchingSessionFailed = false;
  bool _matchingTurkishLocale = true;
  int _matchingRoundIndex = 0;
  int _matchingCorrect = 0;
  int _matchingWrong = 0;
  final int matchingTotalRounds = 10;
  final int matchingMaxWrong = 3;
  PuzzleRoundStatus _matchingRoundStatus = PuzzleRoundStatus.playing;
  bool _pendingNextMatching = false;
  // Word puzzle state
  WordPuzzleRound? _currentWordRound;
  bool _loading = false;
  // Session-like flow for word puzzle
  bool _wordSessionActive = false;
  bool _wordSessionCompleted = false;
  bool _wordSessionFailed = false;
  bool _wordTurkishLocale = true;
  int _wordRoundIndex = 0; // 0-based
  int _wordCorrect = 0;
  int _wordWrong = 0;
  final int wordTotalRounds = 10;
  final int wordMaxWrong = 3;
  int _roundHintsUsed = 0; // per-round used hints
  PuzzleRoundStatus _wordRoundStatus = PuzzleRoundStatus.playing;
  bool _pendingNextWord = false;
  Set<int> _usedLetterChipIndices = {}; // track which letter chips are used
  final Map<int, int> _slotToChipIndex = {}; // slot -> chip index mapping

  bool get isLoading => _loading;
  PuzzleProgress getProgress(PuzzleType t) =>
      _progress[t] ?? PuzzleProgress(type: t);
  WordPuzzleRound? get currentWordRound => _currentWordRound;
  bool get wordSessionActive => _wordSessionActive;
  bool get wordSessionCompleted => _wordSessionCompleted;
  bool get wordSessionFailed => _wordSessionFailed;
  int get wordRoundIndex => _wordRoundIndex;
  int get wordCorrect => _wordCorrect;
  int get wordWrong => _wordWrong;
  int get wordAttemptsLeft => wordMaxWrong - _wordWrong;
  int get wordHintsUsed => _roundHintsUsed;
  int get wordHintsTotalEarned => _currentWordRound == null
      ? 0
      : (_currentWordRound!.slots.length) ~/
            3; // total hints per word = floor(len/3)
  int get wordHintsLeft {
    final total = wordHintsTotalEarned;
    final left = total - _roundHintsUsed;
    return left < 0 ? 0 : left;
  }

  bool get canRevealHint =>
      _wordRoundStatus == PuzzleRoundStatus.playing && wordHintsLeft > 0;
  PuzzleRoundStatus get wordRoundStatus => _wordRoundStatus;
  bool get hasPendingNextWord => _pendingNextWord;
  bool isLetterChipUsed(int index) => _usedLetterChipIndices.contains(index);
  MatchingRound? get currentMatchingRound => _currentMatchingRound;
  bool get matchingSessionActive => _matchingSessionActive;
  bool get matchingSessionCompleted => _matchingSessionCompleted;
  bool get matchingSessionFailed => _matchingSessionFailed;
  int get matchingRoundIndex => _matchingRoundIndex;
  int get matchingCorrect => _matchingCorrect;
  int get matchingWrong => _matchingWrong;
  int get matchingAttemptsLeft => matchingMaxWrong - _matchingWrong;
  PuzzleRoundStatus get matchingRoundStatus => _matchingRoundStatus;
  bool get hasPendingNextMatching => _pendingNextMatching;
  int get matchingTotalRoundsCount => matchingTotalRounds;
  int get matchingMaxLives => matchingMaxWrong;
  Map<String, String> get matchingLeftSymbols =>
      _currentMatchingRound?.leftSymbols ?? {};

  Map<String, String?> get matchingUserMatches =>
      _currentMatchingRound?.userMatches ?? {};

  PuzzleProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadProgress();
  }

  void _loadProgress() {
    final raw = _prefs.getString(_progressKey);
    if (raw == null) return;
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      decoded.forEach((key, value) {
        final type = PuzzleType.values.firstWhere(
          (e) => e.name == key,
          orElse: () => PuzzleType.word,
        );
        _progress[type] = PuzzleProgress.fromJson(value);
      });
    } catch (_) {
      // ignore and continue with defaults
    }
  }

  Future<void> _saveProgress() async {
    final map = _progress.map(
      (key, value) => MapEntry(key.name, value.toJson()),
    );
    await _prefs.setString(_progressKey, jsonEncode(map));
  }

  Future<void> startWordSession({required bool turkish}) async {
    _wordSessionActive = true;
    _wordSessionCompleted = false;
    _wordSessionFailed = false;
    _wordTurkishLocale = turkish;
    _wordRoundIndex = 0;
    _wordCorrect = 0;
    _wordWrong = 0;
    _roundHintsUsed = 0;
    _wordRoundStatus = PuzzleRoundStatus.playing;
    _pendingNextWord = false;
    _usedLetterChipIndices.clear();
    _slotToChipIndex.clear();
    await startWordPuzzle(turkish: turkish, showLoading: true);
  }

  Future<void> startWordPuzzle({
    bool turkish = true,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _loading = true;
      notifyListeners();
    }
    try {
      final elements = await _tableService.getElements();
      // choose a random element that has localized name
      final rnd = Random();
      PeriodicElement? e;
      for (int i = 0; i < 20; i++) {
        final candidate = elements[rnd.nextInt(elements.length)];
        final name = turkish ? candidate.trName : candidate.enName;
        if (name != null && name.length >= 3) {
          e = candidate;
          break;
        }
      }
      e ??= elements.firstWhere(
        (x) => (turkish ? x.trName : x.enName) != null,
        orElse: () => elements.first,
      );
      final target = (turkish ? e.trName : e.enName) ?? 'Element';
      final letters = target.replaceAll(' ', '').toUpperCase().split('');
      final shuffledLetters = List<String>.from(letters)..shuffle();

      _currentWordRound = WordPuzzleRound(
        elementName: target,
        shuffled: shuffledLetters,
        slots: List<String?>.filled(target.replaceAll(' ', '').length, null),
        start: DateTime.now(),
      );
      _roundHintsUsed = 0; // reset per new word
      _wordRoundStatus = PuzzleRoundStatus.playing;
      _pendingNextWord = false;
      _usedLetterChipIndices.clear();
      _slotToChipIndex.clear();
    } finally {
      if (showLoading) {
        _loading = false;
      }
      notifyListeners();
    }
  }

  void placeLetter(int slotIndex, String letter, {int? letterChipIndex}) {
    if (_currentWordRound == null) return;
    final slots = List<String?>.from(_currentWordRound!.slots);
    if (slotIndex < 0 || slotIndex >= slots.length) return;
    slots[slotIndex] = letter;
    _currentWordRound = _currentWordRound!.copyWith(slots: slots);

    if (letterChipIndex != null) {
      _usedLetterChipIndices.add(letterChipIndex);
      _slotToChipIndex[slotIndex] = letterChipIndex;
    }

    notifyListeners();
  }

  void clearSlot(int slotIndex) {
    if (_currentWordRound == null) return;
    final slots = List<String?>.from(_currentWordRound!.slots);
    if (slotIndex < 0 || slotIndex >= slots.length) return;
    slots[slotIndex] = null;
    _currentWordRound = _currentWordRound!.copyWith(slots: slots);

    final chipIndex = _slotToChipIndex.remove(slotIndex);
    if (chipIndex != null) {
      _usedLetterChipIndices.remove(chipIndex);
    }

    notifyListeners();
  }

  /// Reveals one correct letter at a random mismatched or empty slot.
  /// Uses session hint allowance: 1 hint per 3 words reached.
  /// Returns true if a letter was revealed, false if not available or nothing to reveal.
  bool revealHintLetter() {
    if (_currentWordRound == null) return false;
    if (!canRevealHint) return false;
    final expected = _currentWordRound!.elementName
        .replaceAll(' ', '')
        .toUpperCase();
    final slots = List<String?>.from(_currentWordRound!.slots);
    final mismatchedIndexes = <int>[];
    for (int i = 0; i < slots.length; i++) {
      final current = slots[i]?.toUpperCase();
      if (current != expected[i]) mismatchedIndexes.add(i);
    }
    if (mismatchedIndexes.isEmpty) return false;
    final rnd = Random();
    final pick = mismatchedIndexes[rnd.nextInt(mismatchedIndexes.length)];
    final revealedLetter = expected[pick];
    slots[pick] = revealedLetter;
    _currentWordRound = _currentWordRound!.copyWith(slots: slots);
    _roundHintsUsed += 1;

    // Find and mark the corresponding letter chip as used
    final shuffledLetters = _currentWordRound!.shuffled;
    for (int i = 0; i < shuffledLetters.length; i++) {
      if (shuffledLetters[i] == revealedLetter &&
          !_usedLetterChipIndices.contains(i)) {
        _usedLetterChipIndices.add(i);
        _slotToChipIndex[pick] = i;
        break; // Only mark the first unused occurrence
      }
    }

    // If hint reveals final letter, next round will auto-load on submitWord from UI
    notifyListeners();
    return true;
  }

  bool submitWord() {
    if (_currentWordRound == null) return false;
    final expected = _currentWordRound!.elementName
        .replaceAll(' ', '')
        .toUpperCase();
    final actual = _currentWordRound!.currentWord.toUpperCase();
    final success = expected == actual;
    final elapsed = DateTime.now().difference(_currentWordRound!.start);

    final p = getProgress(PuzzleType.word);
    final updated = p.copyWith(
      totalPlays: p.totalPlays + 1,
      totalWins: p.totalWins + (success ? 1 : 0),
      totalTime: p.totalTime + elapsed,
      bestTime:
          (success && (p.bestTime == Duration.zero || elapsed < p.bestTime))
          ? elapsed
          : p.bestTime,
    );
    _progress[PuzzleType.word] = updated;
    _saveProgress();
    _wordRoundStatus = success
        ? PuzzleRoundStatus.success
        : PuzzleRoundStatus.failure;

    if (_wordSessionActive) {
      if (success) {
        _wordCorrect += 1;
      } else {
        _wordWrong += 1;
      }
      _wordRoundIndex += 1;

      if (_wordWrong >= wordMaxWrong) {
        _wordSessionActive = false;
        _wordSessionFailed = true;
        _pendingNextWord = false;
      } else if (_wordRoundIndex >= wordTotalRounds) {
        _wordSessionActive = false;
        _wordSessionCompleted = true;
        _pendingNextWord = false;
      } else {
        _pendingNextWord = true;
      }
    }

    notifyListeners();
    return success;
  }

  Future<void> loadNextWord() async {
    if (!_pendingNextWord || !_wordSessionActive) return;
    _pendingNextWord = false;
    await startWordPuzzle(turkish: _wordTurkishLocale, showLoading: false);
  }

  void resetWordSessionFlags() {
    _wordSessionCompleted = false;
    _wordSessionFailed = false;
    _wordRoundStatus = PuzzleRoundStatus.playing;
    _pendingNextWord = false;
    notifyListeners();
  }

  Future<void> startMatchingSession({required bool turkish}) async {
    _matchingSessionActive = true;
    _matchingSessionCompleted = false;
    _matchingSessionFailed = false;
    _matchingTurkishLocale = turkish;
    _matchingRoundIndex = 0;
    _matchingCorrect = 0;
    _matchingWrong = 0;
    _matchingRoundStatus = PuzzleRoundStatus.playing;
    _pendingNextMatching = false;
    await startMatchingRound(turkish: turkish, showLoading: true);
  }

  Future<void> startMatchingRound({
    bool turkish = true,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      _loading = true;
      notifyListeners();
    }
    try {
      final elements = await _tableService.getElements();
      final rnd = Random();
      // Fixed pair count for all levels
      const int desiredCount = 5;
      final selected = <PeriodicElement>{};
      while (selected.length < desiredCount &&
          selected.length < elements.length) {
        selected.add(elements[rnd.nextInt(elements.length)]);
      }

      final leftItems = <String>[];
      final userMatches = <String, String?>{};
      final correctPairs = <String, String>{};
      final leftSymbols = <String, String>{};

      void addElement(PeriodicElement element) {
        final number = (element.number ?? 0).toString();
        if (number.isEmpty || leftItems.contains(number)) return;
        final name =
            (turkish ? element.trName : element.enName) ??
            element.enName ??
            number;
        final symbol = element.symbol ?? element.enName ?? '';
        leftItems.add(number);
        userMatches[number] = null;
        correctPairs[number] = name;
        leftSymbols[number] = symbol;
      }

      for (final element in selected) {
        addElement(element);
      }

      for (final element in elements) {
        if (leftItems.length >= desiredCount) break;
        addElement(element);
      }

      final rightItems = correctPairs.values.toList();
      rightItems.shuffle();

      _currentMatchingRound = MatchingRound(
        leftItems: leftItems,
        rightItems: rightItems,
        userMatches: userMatches,
        correctPairs: correctPairs,
        leftSymbols: leftSymbols,
        start: DateTime.now(),
      );
      _matchingRoundStatus = PuzzleRoundStatus.playing;
      _pendingNextMatching = false;
    } finally {
      if (showLoading) {
        _loading = false;
      }
      notifyListeners();
    }
  }

  void setMatching(String leftSymbol, String rightValue) {
    if (_currentMatchingRound == null) return;
    if (_matchingRoundStatus != PuzzleRoundStatus.playing) return;
    final current = _currentMatchingRound!;
    final updatedMatches = Map<String, String?>.from(current.userMatches);
    if (!updatedMatches.containsKey(leftSymbol)) return;

    updatedMatches.updateAll(
      (key, value) => value == rightValue ? null : value,
    );
    updatedMatches[leftSymbol] = rightValue;

    _currentMatchingRound = current.copyWith(userMatches: updatedMatches);
    notifyListeners();

    if (updatedMatches.values.where((value) => value != null).length ==
        current.correctPairs.length) {
      submitMatchingRound();
    }
  }

  void clearMatching() {
    if (_currentMatchingRound == null) return;
    final updated = Map<String, String?>.from(
      _currentMatchingRound!.userMatches,
    ).map((key, value) => MapEntry(key, null));
    _currentMatchingRound = _currentMatchingRound!.copyWith(
      userMatches: updated,
    );
    _matchingRoundStatus = PuzzleRoundStatus.playing;
    notifyListeners();
  }

  bool submitMatchingRound() {
    if (_currentMatchingRound == null) return false;
    final current = _currentMatchingRound!;
    final success = current.userMatches.entries.every(
      (entry) => entry.value == current.correctPairs[entry.key],
    );
    final elapsed = DateTime.now().difference(current.start);

    _currentMatchingRound = current.copyWith(end: DateTime.now());
    _matchingRoundStatus = success
        ? PuzzleRoundStatus.success
        : PuzzleRoundStatus.failure;

    final progress = getProgress(PuzzleType.matching);
    _progress[PuzzleType.matching] = progress.copyWith(
      totalPlays: progress.totalPlays + 1,
      totalWins: progress.totalWins + (success ? 1 : 0),
      totalTime: progress.totalTime + elapsed,
      bestTime:
          (success &&
              (progress.bestTime == Duration.zero ||
                  elapsed < progress.bestTime))
          ? elapsed
          : progress.bestTime,
    );
    _saveProgress();

    if (_matchingSessionActive) {
      if (success) {
        _matchingCorrect += 1;
      } else {
        _matchingWrong += 1;
      }
      _matchingRoundIndex += 1;

      if (_matchingWrong >= matchingMaxWrong) {
        _matchingSessionActive = false;
        _matchingSessionFailed = true;
        _pendingNextMatching = false;
      } else if (_matchingRoundIndex >= matchingTotalRounds) {
        _matchingSessionActive = false;
        _matchingSessionCompleted = true;
        _pendingNextMatching = false;
      } else {
        _pendingNextMatching = true;
      }
    }

    notifyListeners();
    return success;
  }

  Future<void> loadNextMatchingRound() async {
    if (!_pendingNextMatching || !_matchingSessionActive) return;
    _pendingNextMatching = false;
    await startMatchingRound(
      turkish: _matchingTurkishLocale,
      showLoading: false,
    );
  }

  void resetMatchingSessionFlags() {
    _matchingSessionCompleted = false;
    _matchingSessionFailed = false;
    _matchingRoundStatus = PuzzleRoundStatus.playing;
    _pendingNextMatching = false;
    notifyListeners();
  }

  /// Reward-continue for Matching: grant +1 attempt and resume current round
  void continueMatchingAfterReward() {
    if (!_matchingSessionActive) return;
    if (_matchingSessionFailed && _matchingWrong >= matchingMaxWrong) {
      // Reduce one wrong to effectively grant one more life in current session
      _matchingSessionFailed = false;
      if (_matchingWrong > 0) _matchingWrong -= 1;
    }
    // Move to next round by marking current as pending next and loading it
    _matchingRoundStatus = PuzzleRoundStatus.playing;
    _pendingNextMatching = true;
    // Load a fresh round immediately
    loadNextMatchingRound();
    notifyListeners();
  }

  /// Reward-continue for Word: grant +1 attempt and resume current word
  void continueWordAfterReward() {
    if (!_wordSessionActive) return;
    if (_wordSessionFailed && _wordWrong >= wordMaxWrong) {
      _wordSessionFailed = false;
      if (_wordWrong > 0) _wordWrong -= 1;
    }
    // Mark to load next word and trigger it
    _wordRoundStatus = PuzzleRoundStatus.playing;
    _pendingNextWord = true;
    loadNextWord();
    notifyListeners();
  }

  /// Clears all puzzle progress data
  void clearAllProgress() {
    _progress.clear();
    _prefs.remove(_progressKey);
    notifyListeners();
    debugPrint('🗑️ All puzzle progress cleared from memory and cache');
  }

  /// Clears progress for a specific puzzle type
  void clearProgressForType(PuzzleType type) {
    _progress.remove(type);
    _saveProgress();
    notifyListeners();
    debugPrint('🗑️ Progress cleared for ${type.name} puzzle');
  }
}

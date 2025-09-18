import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central provider to manage Element Trivia statistics and achievements
class TriviaProvider extends ChangeNotifier {
  static const String _storageKey = 'trivia_statistics';

  late SharedPreferences _prefs;

  int _totalGamesPlayed = 0;
  int _totalWins = 0;
  int _totalCorrectAnswers = 0;
  int _totalWrongAnswers = 0;
  Duration _totalTimePlayed = Duration.zero;
  Duration _bestTime = Duration.zero;
  int _currentStreak = 0;
  int _longestStreak = 0;

  // Per-category statistics
  final Map<TriviaCategory, TriviaCategoryStats> _categoryStats = {
    for (final c in TriviaCategory.values) c: const TriviaCategoryStats(),
  };

  TriviaProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final String? jsonStr = _prefs.getString(_storageKey);
    if (jsonStr == null) return;
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      _totalGamesPlayed = data['totalGamesPlayed'] ?? 0;
      _totalWins = data['totalWins'] ?? 0;
      _totalCorrectAnswers = data['totalCorrectAnswers'] ?? 0;
      _totalWrongAnswers = data['totalWrongAnswers'] ?? 0;
      _totalTimePlayed = Duration(seconds: data['totalTimePlayed'] ?? 0);
      _bestTime = Duration(seconds: data['bestTime'] ?? 0);
      _currentStreak = data['currentStreak'] ?? 0;
      _longestStreak = data['longestStreak'] ?? 0;
      final catMap = (data['categories'] as Map?) ?? {};
      for (final c in TriviaCategory.values) {
        final raw = catMap[c.name];
        if (raw is Map<String, dynamic>) {
          _categoryStats[c] = TriviaCategoryStats.fromJson(raw);
        }
      }
    } catch (_) {
      // ignore parse errors
    }
  }

  Future<void> _saveToPrefs() async {
    final data = {
      'totalGamesPlayed': _totalGamesPlayed,
      'totalWins': _totalWins,
      'totalCorrectAnswers': _totalCorrectAnswers,
      'totalWrongAnswers': _totalWrongAnswers,
      'totalTimePlayed': _totalTimePlayed.inSeconds,
      'bestTime': _bestTime.inSeconds,
      'currentStreak': _currentStreak,
      'longestStreak': _longestStreak,
      'categories': {
        for (final e in _categoryStats.entries) e.key.name: e.value.toJson(),
      },
    };
    await _prefs.setString(_storageKey, jsonEncode(data));
  }

  // Getters
  int get totalGamesPlayed => _totalGamesPlayed;
  int get totalWins => _totalWins;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalWrongAnswers => _totalWrongAnswers;
  Duration get totalTimePlayed => _totalTimePlayed;
  Duration get bestTime => _bestTime;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

  double get winRate =>
      _totalGamesPlayed == 0 ? 0.0 : _totalWins / _totalGamesPlayed.toDouble();

  TriviaCategoryStats getCategoryStats(TriviaCategory c) =>
      _categoryStats[c] ?? const TriviaCategoryStats();

  /// Call at the end of a trivia game to update aggregated stats
  Future<void> updateAfterGame({
    required bool isWin,
    required int correct,
    required int wrong,
    required Duration gameTime,
    required TriviaCategory category,
  }) async {
    _totalGamesPlayed += 1;
    if (isWin) {
      _totalWins += 1;
      _currentStreak += 1;
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }
    _totalCorrectAnswers += correct;
    _totalWrongAnswers += wrong;
    _totalTimePlayed += gameTime;
    if (isWin && (_bestTime == Duration.zero || gameTime < _bestTime)) {
      _bestTime = gameTime;
    }
    // per-category
    final cs = _categoryStats[category] ?? const TriviaCategoryStats();
    final updated = cs.copyWith(
      totalGamesPlayed: cs.totalGamesPlayed + 1,
      totalWins: cs.totalWins + (isWin ? 1 : 0),
      totalTimePlayed: cs.totalTimePlayed + gameTime,
      bestTime:
          (isWin && (cs.bestTime == Duration.zero || gameTime < cs.bestTime))
          ? gameTime
          : cs.bestTime,
    );
    _categoryStats[category] = updated;
    await _saveToPrefs();
    notifyListeners();
  }

  /// Clears all trivia statistics
  void clearAll() {
    _totalGamesPlayed = 0;
    _totalWins = 0;
    _totalCorrectAnswers = 0;
    _totalWrongAnswers = 0;
    _totalTimePlayed = Duration.zero;
    _bestTime = Duration.zero;
    _currentStreak = 0;
    _longestStreak = 0;
    for (final c in TriviaCategory.values) {
      _categoryStats[c] = const TriviaCategoryStats();
    }
    _prefs.remove(_storageKey);
    notifyListeners();
  }
}

enum TriviaCategory {
  classification,
  weight,
  period,
  description,
  usage,
  source,
  mixed,
}

class TriviaCategoryStats {
  final int totalGamesPlayed;
  final int totalWins;
  final Duration totalTimePlayed;
  final Duration bestTime;

  const TriviaCategoryStats({
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalTimePlayed = Duration.zero,
    this.bestTime = Duration.zero,
  });

  double get winRate =>
      totalGamesPlayed == 0 ? 0.0 : totalWins / totalGamesPlayed.toDouble();

  TriviaCategoryStats copyWith({
    int? totalGamesPlayed,
    int? totalWins,
    Duration? totalTimePlayed,
    Duration? bestTime,
  }) {
    return TriviaCategoryStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      bestTime: bestTime ?? this.bestTime,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGamesPlayed': totalGamesPlayed,
    'totalWins': totalWins,
    'totalTimePlayed': totalTimePlayed.inSeconds,
    'bestTime': bestTime.inSeconds,
  };

  factory TriviaCategoryStats.fromJson(Map<String, dynamic> json) {
    return TriviaCategoryStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalTimePlayed: Duration(seconds: json['totalTimePlayed'] ?? 0),
      bestTime: Duration(seconds: json['bestTime'] ?? 0),
    );
  }
}

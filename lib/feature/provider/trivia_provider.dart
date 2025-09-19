import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TriviaBadgeCategory { games, wins, accuracy, speed, streak }

class TriviaBadge {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final TriviaBadgeCategory category;
  final bool earned;
  final DateTime? earnedAt;

  const TriviaBadge({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.category,
    this.earned = false,
    this.earnedAt,
  });

  TriviaBadge copyWith({
    String? id,
    String? titleTr,
    String? titleEn,
    String? descriptionTr,
    String? descriptionEn,
    TriviaBadgeCategory? category,
    bool? earned,
    DateTime? earnedAt,
  }) {
    return TriviaBadge(
      id: id ?? this.id,
      titleTr: titleTr ?? this.titleTr,
      titleEn: titleEn ?? this.titleEn,
      descriptionTr: descriptionTr ?? this.descriptionTr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      category: category ?? this.category,
      earned: earned ?? this.earned,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titleTr': titleTr,
    'titleEn': titleEn,
    'descriptionTr': descriptionTr,
    'descriptionEn': descriptionEn,
    'category': category.name,
    'earned': earned,
    'earnedAt': earnedAt?.millisecondsSinceEpoch,
  };

  factory TriviaBadge.fromJson(Map<String, dynamic> json) => TriviaBadge(
    id: json['id'] ?? '',
    titleTr: json['titleTr'] ?? '',
    titleEn: json['titleEn'] ?? '',
    descriptionTr: json['descriptionTr'] ?? '',
    descriptionEn: json['descriptionEn'] ?? '',
    category: TriviaBadgeCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => TriviaBadgeCategory.games,
    ),
    earned: json['earned'] ?? false,
    earnedAt: json['earnedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['earnedAt'])
        : null,
  );
}

/// Central provider to manage Element Trivia statistics and achievements
class TriviaProvider extends ChangeNotifier {
  static const String _storageKey = 'trivia_statistics';
  static const String _achievementsKey = 'trivia_achievements_v1';

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

  // Achievements
  Map<TriviaCategory, List<TriviaBadge>> _achievements = {};
  List<TriviaBadge> _lastEarnedBadges = [];

  TriviaProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
    _loadAchievements();
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

  void _loadAchievements() {
    final String? jsonStr = _prefs.getString(_achievementsKey);
    if (jsonStr == null) return;
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      decoded.forEach((key, value) {
        final category = TriviaCategory.values.firstWhere(
          (c) => c.name == key,
          orElse: () => TriviaCategory.mixed,
        );
        final list = (value as List)
            .map((e) => TriviaBadge.fromJson(e as Map<String, dynamic>))
            .toList();
        _achievements[category] = list;
      });
    } catch (e) {
      debugPrint('❌ Error loading trivia achievements: $e');
      _achievements = {};
    }
  }

  Future<void> _saveAchievements() async {
    try {
      // Ensure defaults present
      for (final c in TriviaCategory.values) {
        _achievements[c] = _achievements[c] ?? _defaultBadgesForCategory(c);
      }
      final data = _achievements.map(
        (key, value) =>
            MapEntry(key.name, value.map((b) => b.toJson()).toList()),
      );
      await _prefs.setString(_achievementsKey, jsonEncode(data));
    } catch (e) {
      debugPrint('❌ Error saving trivia achievements: $e');
    }
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

  /// Returns badges for a category, ensuring defaults exist
  List<TriviaBadge> getAchievementsForCategory(TriviaCategory category) {
    _achievements[category] =
        _achievements[category] ?? _defaultBadgesForCategory(category);
    return _achievements[category]!;
  }

  /// Total earned badges across all categories
  int getTotalEarnedBadges() {
    for (final c in TriviaCategory.values) {
      _achievements[c] = _achievements[c] ?? _defaultBadgesForCategory(c);
    }
    return _achievements.values
        .expand((list) => list)
        .where((b) => b.earned)
        .length;
  }

  /// Total badges available
  int getTotalBadgesCount() {
    for (final c in TriviaCategory.values) {
      _achievements[c] = _achievements[c] ?? _defaultBadgesForCategory(c);
    }
    return _achievements.values.expand((e) => e).length;
  }

  /// Returns and clears badges earned during the last evaluation
  List<TriviaBadge> consumeLastEarnedBadges() {
    final res = List<TriviaBadge>.from(_lastEarnedBadges);
    _lastEarnedBadges.clear();
    return res;
  }

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
    _evaluateAndAwardBadges(category);
    await _saveToPrefs();
    notifyListeners();
  }

  /// Evaluate and mark badges as earned based on current statistics
  void _evaluateAndAwardBadges(TriviaCategory category) {
    final stats = getCategoryStats(category);
    final badges = getAchievementsForCategory(category);
    final previousById = {for (final b in badges) b.id: b};

    bool changed = false;
    TriviaBadge setEarned(TriviaBadge b) => b.copyWith(
      earned: true,
      earnedAt: b.earned ? b.earnedAt : DateTime.now(),
    );

    final wins = stats.totalWins;
    final plays = stats.totalGamesPlayed;
    final bestTimeSec = stats.bestTime.inSeconds;
    final winRate = stats.winRate;

    final updated = badges.map((b) {
      if (b.earned) return b;

      if (b.category == TriviaBadgeCategory.games) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if (plays >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == TriviaBadgeCategory.wins) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if (wins >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == TriviaBadgeCategory.accuracy) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if ((winRate * 100).round() >= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      if (b.category == TriviaBadgeCategory.speed) {
        final threshold = int.tryParse(b.id.split('_').last) ?? 0;
        if (bestTimeSec > 0 && bestTimeSec <= threshold) {
          changed = true;
          return setEarned(b);
        }
      }
      return b;
    }).toList();

    if (changed) {
      _achievements[category] = updated;
      // Compute newly earned
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

  /// Default badge set for a trivia category
  List<TriviaBadge> _defaultBadgesForCategory(TriviaCategory category) {
    final badges = <TriviaBadge>[];

    // Games played badges
    for (final t in [5, 10, 25, 50]) {
      badges.add(
        TriviaBadge(
          id: 'games_$t',
          titleTr: '$t Oyun',
          titleEn: '$t Games',
          descriptionTr: '$t trivia oyunu oyna',
          descriptionEn: 'Play $t trivia games',
          category: TriviaBadgeCategory.games,
        ),
      );
    }

    // Wins badges
    for (final t in [1, 5, 10, 25]) {
      badges.add(
        TriviaBadge(
          id: 'wins_$t',
          titleTr: t == 1 ? 'İlk Zafer' : '$t Zafer',
          titleEn: t == 1 ? 'First Win' : '$t Wins',
          descriptionTr: t == 1
              ? 'İlk trivia oyununu kazan'
              : '$t trivia oyunu kazan',
          descriptionEn: t == 1
              ? 'Win first trivia game'
              : 'Win $t trivia games',
          category: TriviaBadgeCategory.wins,
        ),
      );
    }

    // Accuracy badges (percentage)
    for (final t in [70, 80, 90, 100]) {
      badges.add(
        TriviaBadge(
          id: 'accuracy_$t',
          titleTr: t == 100 ? 'Mükemmel' : '%$t Doğruluk',
          titleEn: t == 100 ? 'Perfect' : '$t% Accuracy',
          descriptionTr: t == 100
              ? 'Mükemmel doğruluk oranı'
              : '%$t doğruluk oranına ulaş',
          descriptionEn: t == 100
              ? 'Achieve perfect accuracy'
              : 'Reach $t% accuracy',
          category: TriviaBadgeCategory.accuracy,
        ),
      );
    }

    // Speed badges (in seconds)
    for (final t in [90, 60, 30]) {
      badges.add(
        TriviaBadge(
          id: 'speed_$t',
          titleTr: t == 90 ? 'Hızlı' : (t == 60 ? 'Çok Hızlı' : 'Şimşek'),
          titleEn: t == 90 ? 'Fast' : (t == 60 ? 'Very Fast' : 'Lightning'),
          descriptionTr: '${t}s altında tamamla',
          descriptionEn: 'Complete under ${t}s',
          category: TriviaBadgeCategory.speed,
        ),
      );
    }

    return badges;
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

import 'package:equatable/equatable.dart';

enum PuzzleType { word, crossword, matching, placement }

class PuzzleProgress extends Equatable {
  final PuzzleType type;
  final int totalPlays;
  final int totalWins;
  final Duration totalTime;
  final Duration bestTime;

  const PuzzleProgress({
    required this.type,
    this.totalPlays = 0,
    this.totalWins = 0,
    this.totalTime = Duration.zero,
    this.bestTime = Duration.zero,
  });

  PuzzleProgress copyWith({
    int? totalPlays,
    int? totalWins,
    Duration? totalTime,
    Duration? bestTime,
  }) => PuzzleProgress(
    type: type,
    totalPlays: totalPlays ?? this.totalPlays,
    totalWins: totalWins ?? this.totalWins,
    totalTime: totalTime ?? this.totalTime,
    bestTime: bestTime ?? this.bestTime,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'totalPlays': totalPlays,
    'totalWins': totalWins,
    'totalTime': totalTime.inMilliseconds,
    'bestTime': bestTime.inMilliseconds,
  };

  factory PuzzleProgress.fromJson(Map<String, dynamic> json) => PuzzleProgress(
    type: PuzzleType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => PuzzleType.word,
    ),
    totalPlays: json['totalPlays'] ?? 0,
    totalWins: json['totalWins'] ?? 0,
    totalTime: Duration(milliseconds: json['totalTime'] ?? 0),
    bestTime: Duration(milliseconds: json['bestTime'] ?? 0),
  );

  @override
  List<Object?> get props => [type, totalPlays, totalWins, totalTime, bestTime];
}

// Word puzzle round: unscramble element name from shuffled letters
class WordPuzzleRound extends Equatable {
  final String elementName; // localized name shown as target
  final List<String> shuffled; // shuffled letters to pick from
  final List<String?> slots; // user-filled slots
  final DateTime start;

  const WordPuzzleRound({
    required this.elementName,
    required this.shuffled,
    required this.slots,
    required this.start,
  });

  bool get isFilled => slots.every((s) => s != null);
  String get currentWord => slots.map((e) => e ?? '').join();

  WordPuzzleRound copyWith({List<String>? shuffled, List<String?>? slots}) =>
      WordPuzzleRound(
        elementName: elementName,
        shuffled: shuffled ?? this.shuffled,
        slots: slots ?? this.slots,
        start: start,
      );

  @override
  List<Object?> get props => [elementName, shuffled, slots, start];
}

class MatchingRound extends Equatable {
  final List<String> leftItems;
  final List<String> rightItems;
  final Map<String, String?> userMatches;
  final Map<String, String> correctPairs;
  final Map<String, String> leftSymbols;
  final DateTime start;
  final DateTime? end;

  const MatchingRound({
    required this.leftItems,
    required this.rightItems,
    required this.userMatches,
    required this.correctPairs,
    required this.leftSymbols,
    required this.start,
    this.end,
  });

  bool get isFilled =>
      userMatches.values.where((value) => value != null).length ==
      leftItems.length;

  MatchingRound copyWith({
    List<String>? leftItems,
    List<String>? rightItems,
    Map<String, String?>? userMatches,
    Map<String, String>? correctPairs,
    Map<String, String>? leftSymbols,
    DateTime? start,
    DateTime? end,
  }) {
    return MatchingRound(
      leftItems: leftItems ?? this.leftItems,
      rightItems: rightItems ?? this.rightItems,
      userMatches: userMatches ?? this.userMatches,
      correctPairs: correctPairs ?? this.correctPairs,
      leftSymbols: leftSymbols ?? this.leftSymbols,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  List<Object?> get props => [
    leftItems,
    rightItems,
    userMatches,
    correctPairs,
    leftSymbols,
    start,
    end,
  ];
}

// Matching puzzle pair
class MatchingItem extends Equatable {
  final String left; // e.g., element symbol
  final String right; // e.g., element name
  const MatchingItem(this.left, this.right);

  @override
  List<Object?> get props => [left, right];
}

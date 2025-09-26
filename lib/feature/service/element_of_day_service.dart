import 'dart:math';
import 'package:elements_app/feature/model/periodic_element.dart';

/// Service to get the element of the day based on the current date
class ElementOfDayService {
  static const List<int> _elementNumbers = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114,
    115,
    116,
    117,
    118,
  ];

  /// Gets the element of the day based on the current date
  /// Uses the day of the year to ensure the same element is shown for the entire day
  /// Changes at 00:00 every day
  static int getElementOfDayNumber() {
    final now = DateTime.now();
    // Use year, month, and day to ensure different element each day at 00:00
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;

    // Create a seed based on year and day of year for consistent daily element
    final seed = now.year * 1000 + dayOfYear;
    final random = Random(seed);
    return _elementNumbers[random.nextInt(_elementNumbers.length)];
  }

  /// Gets a random element number (for testing or special cases)
  static int getRandomElementNumber() {
    final random = Random();
    return _elementNumbers[random.nextInt(_elementNumbers.length)];
  }

  /// Gets the element of the day from a list of elements
  static PeriodicElement? getElementOfDay(List<PeriodicElement> elements) {
    if (elements.isEmpty) return null;
    final now = DateTime.now();
    final seed = int.parse('${now.year}${now.month}${now.day}');
    final rng = Random(seed);
    final selectedElement = elements[rng.nextInt(elements.length)];

    // Debug: Print selected element
    print(
      'Flutter App - Selected Element: ${selectedElement.symbol} (${selectedElement.enName})',
    );
    print('Flutter App - Seed: $seed, Random: ${rng.nextInt(elements.length)}');
    print('Flutter App - Element Number: ${selectedElement.number}');
    print('Flutter App - Element Weight: ${selectedElement.weight}');
    print('Flutter App - Element Category: ${selectedElement.enCategory}');

    return selectedElement;
  }

  /// Gets the element of the day for a specific date
  static int getElementOfDayForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final random = Random(dayOfYear);
    return _elementNumbers[random.nextInt(_elementNumbers.length)];
  }

  static Map<String, String> buildWidgetPayload(PeriodicElement e) {
    return {
      'number': (e.number ?? 0).toString(),
      'symbol': e.symbol ?? '',
      'enName': e.enName ?? '',
      'trName': e.trName ?? '',
      'weight': e.weight ?? '',
      'category': e.enCategory ?? '',
    };
  }
}

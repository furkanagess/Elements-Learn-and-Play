import 'dart:math';
import 'package:elements_app/feature/service/element_of_day_service.dart';
import 'package:elements_app/feature/model/periodic_element.dart';

/// Helper class to test widget updates and element calculations
class WidgetTestHelper {
  /// Test element calculation for different dates
  static void testElementCalculations() {
    print('=== Widget Test Helper ===');

    // Test today's element
    final today = DateTime.now();
    final todayElement = _getElementForDate(today);
    print(
      'Today (${_formatDate(today)}): ${todayElement.symbol} - ${todayElement.enName}',
    );

    // Test tomorrow's element
    final tomorrow = today.add(Duration(days: 1));
    final tomorrowElement = _getElementForDate(tomorrow);
    print(
      'Tomorrow (${_formatDate(tomorrow)}): ${tomorrowElement.symbol} - ${tomorrowElement.enName}',
    );

    // Test next week's element
    final nextWeek = today.add(Duration(days: 7));
    final nextWeekElement = _getElementForDate(nextWeek);
    print(
      'Next Week (${_formatDate(nextWeek)}): ${nextWeekElement.symbol} - ${nextWeekElement.enName}',
    );

    // Test if elements are different
    final elementsAreDifferent = todayElement.symbol != tomorrowElement.symbol;
    print('Elements change daily: $elementsAreDifferent');

    print('=== End Test ===');
  }

  /// Get element for a specific date using the same algorithm as the service
  static PeriodicElement _getElementForDate(DateTime date) {
    // Create a mock elements list (simplified for testing)
    final mockElements = <PeriodicElement>[
      PeriodicElement(
        number: 1,
        symbol: 'H',
        enName: 'Hydrogen',
        trName: 'Hidrojen',
        weight: '1.008',
        enCategory: 'Nonmetal',
      ),
      PeriodicElement(
        number: 2,
        symbol: 'He',
        enName: 'Helium',
        trName: 'Helyum',
        weight: '4.003',
        enCategory: 'Noble Gas',
      ),
      PeriodicElement(
        number: 6,
        symbol: 'C',
        enName: 'Carbon',
        trName: 'Karbon',
        weight: '12.011',
        enCategory: 'Nonmetal',
      ),
      PeriodicElement(
        number: 26,
        symbol: 'Fe',
        enName: 'Iron',
        trName: 'Demir',
        weight: '55.845',
        enCategory: 'Transition Metal',
      ),
      PeriodicElement(
        number: 79,
        symbol: 'Au',
        enName: 'Gold',
        trName: 'Altın',
        weight: '196.967',
        enCategory: 'Transition Metal',
      ),
    ];

    // Use the same algorithm as ElementOfDayService
    final seed = int.parse('${date.year}${date.month}${date.day}');
    final rng = Random(seed);
    return mockElements[rng.nextInt(mockElements.length)];
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

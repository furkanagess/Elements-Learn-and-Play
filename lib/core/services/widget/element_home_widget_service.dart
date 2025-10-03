import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/service/element_of_day_service.dart';
import 'package:elements_app/feature/provider/periodicTable/periodic_table_provider.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

class ElementHomeWidgetService {
  static const String iOSWidgetName = 'ElementOfDayWidget';
  static const String androidWidgetName = 'ElementOfDayWidgetProvider';

  static Future<void> updateFromContext(BuildContext context) async {
    try {
      final elements = context.read<PeriodicTableProvider>().state.elements;
      final element = ElementOfDayService.getElementOfDay(elements);
      if (element == null) return;
      await _updateWidget(element);
    } catch (e) {
      // Handle error silently
      print('Widget update error: $e');
    }
  }

  static Future<void> updateWidgetDirectly(PeriodicElement element) async {
    try {
      await _updateWidget(element);
    } catch (e) {
      print('Widget update error: $e');
    }
  }

  static Future<void> _updateWidget(PeriodicElement element) async {
    final data = ElementOfDayService.buildWidgetPayload(element);

    // Debug: Print widget data being saved
    print(
      'Flutter Widget Service - Saving element: ${element.symbol} (${element.enName})',
    );
    print('Flutter Widget Service - Data: $data');
    print('Flutter Widget Service - Element Number: ${element.number}');
    print('Flutter Widget Service - Element Weight: ${element.weight}');
    print('Flutter Widget Service - Element Category: ${element.enCategory}');

    // Save widget data with App Group for iOS
    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData(entry.key, entry.value);
      print('Flutter Widget Service - Saved: ${entry.key} = ${entry.value}');
    }

    // Update widget
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iOSWidgetName,
    );

    print('Flutter Widget Service - Widget update requested');
  }

  static Future<void> forceUpdate() async {
    try {
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      print('Force update error: $e');
    }
  }

  /// Schedule daily widget updates at midnight
  static Future<void> scheduleDailyUpdates() async {
    try {
      // For iOS, we rely on the widget's timeline to handle updates
      // For Android, we schedule a daily update using WorkManager or similar
      await _scheduleAndroidDailyUpdate();
    } catch (e) {
      print('Schedule daily updates error: $e');
    }
  }

  static Future<void> _scheduleAndroidDailyUpdate() async {
    // This would typically use WorkManager for Android
    // For now, we'll rely on the Android widget's AlarmManager
    print('Android daily update scheduling handled by widget provider');
  }
}

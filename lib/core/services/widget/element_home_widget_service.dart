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

    // Save widget data
    for (final entry in data.entries) {
      await HomeWidget.saveWidgetData(entry.key, entry.value);
    }

    // Update widget
    await HomeWidget.updateWidget(
      name: androidWidgetName,
      iOSName: iOSWidgetName,
    );
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
}

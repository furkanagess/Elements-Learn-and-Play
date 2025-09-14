import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/product/widget/card/element_card.dart';
import 'package:flutter/material.dart';

/// List view component for displaying elements in list format
class ElementsListWidget extends StatelessWidget {
  final List<PeriodicElement> elements;

  const ElementsListWidget({super.key, required this.elements});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return ElementCard(
          element: element,
          mode: ElementCardMode.list,
          index: index,
        );
      },
    );
  }
}

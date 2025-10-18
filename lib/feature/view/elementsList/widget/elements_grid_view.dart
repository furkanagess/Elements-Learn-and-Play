import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/product/widget/card/element_card.dart';
import 'package:flutter/material.dart';

/// Grid view component for displaying elements in grid format
class ElementsGridView extends StatelessWidget {
  final List<PeriodicElement> elements;

  const ElementsGridView({super.key, required this.elements});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.7, // Slightly taller to accommodate atomic weight
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: elements.length,
      itemBuilder: (context, index) {
        final element = elements[index];
        return ElementCard(
          element: element,
          mode: ElementCardMode.grid,
          index: index,
        );
      },
    );
  }
}

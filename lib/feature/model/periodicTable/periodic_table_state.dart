import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:flutter/material.dart';

@immutable
class PeriodicTableState {
  final List<PeriodicElement> elements;
  final double scale;
  final Offset offset;
  final bool isLoading;
  final String? error;
  final PeriodicElement? selectedElement;
  final String? selectedGroup;
  final String? selectedPeriod;
  final bool showElectronicConfig;
  final bool showAtomicModel;

  const PeriodicTableState({
    required this.elements,
    this.scale = 1.0,
    this.offset = Offset.zero,
    this.isLoading = false,
    this.error,
    this.selectedElement,
    this.selectedGroup,
    this.selectedPeriod,
    this.showElectronicConfig = false,
    this.showAtomicModel = false,
  });

  PeriodicTableState copyWith({
    List<PeriodicElement>? elements,
    double? scale,
    Offset? offset,
    bool? isLoading,
    String? error,
    PeriodicElement? selectedElement,
    String? selectedGroup,
    String? selectedPeriod,
    bool? showElectronicConfig,
    bool? showAtomicModel,
  }) {
    return PeriodicTableState(
      elements: elements ?? this.elements,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedElement: selectedElement ?? this.selectedElement,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      showElectronicConfig: showElectronicConfig ?? this.showElectronicConfig,
      showAtomicModel: showAtomicModel ?? this.showAtomicModel,
    );
  }
}

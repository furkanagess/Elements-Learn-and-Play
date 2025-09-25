import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/model/periodicTable/periodic_table_state.dart';
import 'package:elements_app/feature/service/periodicTable/periodic_table_service.dart';
import 'package:elements_app/product/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class PeriodicTableProvider extends ChangeNotifier {
  final PeriodicTableService _service;
  PeriodicTableState _state;

  PeriodicTableProvider(this._service)
    : _state = PeriodicTableState(elements: []);

  PeriodicTableState get state => _state;

  // Zoom ve Pan İşlemleri
  void updateScale(double scale) {
    if (scale >= 0.5 && scale <= 3.0) {
      _state = _state.copyWith(scale: scale);
      notifyListeners();
    }
  }

  void updateOffset(Offset offset) {
    _state = _state.copyWith(offset: offset);
    notifyListeners();
  }

  // Element Seçimi
  void selectElement(PeriodicElement? element) {
    _state = _state.copyWith(
      selectedElement: element,
      showElectronicConfig: false,
      showAtomicModel: false,
    );
    notifyListeners();
  }

  // Grup ve Periyot Seçimi
  void selectGroup(String? group) {
    _state = _state.copyWith(
      selectedGroup: group,
      selectedPeriod: null,
      selectedElement: null,
    );
    notifyListeners();
  }

  void selectPeriod(String? period) {
    _state = _state.copyWith(
      selectedPeriod: period,
      selectedGroup: null,
      selectedElement: null,
    );
    notifyListeners();
  }

  // Görselleştirme Kontrolleri
  void toggleElectronicConfig() {
    _state = _state.copyWith(
      showElectronicConfig: !_state.showElectronicConfig,
      showAtomicModel: false,
    );
    notifyListeners();
  }

  void toggleAtomicModel() {
    _state = _state.copyWith(
      showAtomicModel: !_state.showAtomicModel,
      showElectronicConfig: false,
    );
    notifyListeners();
  }

  // Veri Yükleme
  Future<void> loadElements() async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      final elements = await _service.getElements();
      _state = _state.copyWith(elements: elements, isLoading: false);
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  // Element Filtreleme
  List<PeriodicElement> get filteredElements {
    // Elements listesi boş veya null ise boş liste döndür
    if (_state.elements.isEmpty) {
      return [];
    }

    if (_state.selectedGroup != null) {
      return _state.elements
          .where((e) => e.group == _state.selectedGroup)
          .toList();
    }
    if (_state.selectedPeriod != null) {
      return _state.elements
          .where((e) => e.period == _state.selectedPeriod)
          .toList();
    }
    return _state.elements;
  }

  // Element Pozisyonlama
  Offset getElementPosition(PeriodicElement element) {
    final atomicNumber = int.tryParse(element.number?.toString() ?? '0') ?? 0;

    // Periyodik tablodaki gerçek pozisyonlar
    final positions = {
      // 1. Periyot
      1: const Offset(0, 0), // H
      2: const Offset(17, 0), // He
      // 2. Periyot
      3: const Offset(0, 1), // Li
      4: const Offset(1, 1), // Be
      5: const Offset(12, 1), // B
      6: const Offset(13, 1), // C
      7: const Offset(14, 1), // N
      8: const Offset(15, 1), // O
      9: const Offset(16, 1), // F
      10: const Offset(17, 1), // Ne
      // 3. Periyot
      11: const Offset(0, 2), // Na
      12: const Offset(1, 2), // Mg
      13: const Offset(12, 2), // Al
      14: const Offset(13, 2), // Si
      15: const Offset(14, 2), // P
      16: const Offset(15, 2), // S
      17: const Offset(16, 2), // Cl
      18: const Offset(17, 2), // Ar
      // 4. Periyot
      19: const Offset(0, 3), // K
      20: const Offset(1, 3), // Ca
      21: const Offset(2, 3), // Sc
      22: const Offset(3, 3), // Ti
      23: const Offset(4, 3), // V
      24: const Offset(5, 3), // Cr
      25: const Offset(6, 3), // Mn
      26: const Offset(7, 3), // Fe
      27: const Offset(8, 3), // Co
      28: const Offset(9, 3), // Ni
      29: const Offset(10, 3), // Cu
      30: const Offset(11, 3), // Zn
      31: const Offset(12, 3), // Ga
      32: const Offset(13, 3), // Ge
      33: const Offset(14, 3), // As
      34: const Offset(15, 3), // Se
      35: const Offset(16, 3), // Br
      36: const Offset(17, 3), // Kr
      // 5. Periyot
      37: const Offset(0, 4), // Rb
      38: const Offset(1, 4), // Sr
      39: const Offset(2, 4), // Y
      40: const Offset(3, 4), // Zr
      41: const Offset(4, 4), // Nb
      42: const Offset(5, 4), // Mo
      43: const Offset(6, 4), // Tc
      44: const Offset(7, 4), // Ru
      45: const Offset(8, 4), // Rh
      46: const Offset(9, 4), // Pd
      47: const Offset(10, 4), // Ag
      48: const Offset(11, 4), // Cd
      49: const Offset(12, 4), // In
      50: const Offset(13, 4), // Sn
      51: const Offset(14, 4), // Sb
      52: const Offset(15, 4), // Te
      53: const Offset(16, 4), // I
      54: const Offset(17, 4), // Xe
      // 6. Periyot
      55: const Offset(0, 5), // Cs
      56: const Offset(1, 5), // Ba
      57: const Offset(2, 5), // La
      72: const Offset(3, 5), // Hf
      73: const Offset(4, 5), // Ta
      74: const Offset(5, 5), // W
      75: const Offset(6, 5), // Re
      76: const Offset(7, 5), // Os
      77: const Offset(8, 5), // Ir
      78: const Offset(9, 5), // Pt
      79: const Offset(10, 5), // Au
      80: const Offset(11, 5), // Hg
      81: const Offset(12, 5), // Tl
      82: const Offset(13, 5), // Pb
      83: const Offset(14, 5), // Bi
      84: const Offset(15, 5), // Po
      85: const Offset(16, 5), // At
      86: const Offset(17, 5), // Rn
      // 7. Periyot
      87: const Offset(0, 6), // Fr
      88: const Offset(1, 6), // Ra
      89: const Offset(2, 6), // Ac
      104: const Offset(3, 6), // Rf
      105: const Offset(4, 6), // Db
      106: const Offset(5, 6), // Sg
      107: const Offset(6, 6), // Bh
      108: const Offset(7, 6), // Hs
      109: const Offset(8, 6), // Mt
      110: const Offset(9, 6), // Ds
      111: const Offset(10, 6), // Rg
      112: const Offset(11, 6), // Cn
      113: const Offset(12, 6), // Nh
      114: const Offset(13, 6), // Fl
      115: const Offset(14, 6), // Mc
      116: const Offset(15, 6), // Lv
      117: const Offset(16, 6), // Ts
      118: const Offset(17, 6), // Og
      // Lantanitler (6. Periyot)
      58: const Offset(3, 8), // Ce
      59: const Offset(4, 8), // Pr
      60: const Offset(5, 8), // Nd
      61: const Offset(6, 8), // Pm
      62: const Offset(7, 8), // Sm
      63: const Offset(8, 8), // Eu
      64: const Offset(9, 8), // Gd
      65: const Offset(10, 8), // Tb
      66: const Offset(11, 8), // Dy
      67: const Offset(12, 8), // Ho
      68: const Offset(13, 8), // Er
      69: const Offset(14, 8), // Tm
      70: const Offset(15, 8), // Yb
      71: const Offset(16, 8), // Lu
      // Aktinitler (7. Periyot)
      90: const Offset(3, 9), // Th
      91: const Offset(4, 9), // Pa
      92: const Offset(5, 9), // U
      93: const Offset(6, 9), // Np
      94: const Offset(7, 9), // Pu
      95: const Offset(8, 9), // Am
      96: const Offset(9, 9), // Cm
      97: const Offset(10, 9), // Bk
      98: const Offset(11, 9), // Cf
      99: const Offset(12, 9), // Es
      100: const Offset(13, 9), // Fm
      101: const Offset(14, 9), // Md
      102: const Offset(15, 9), // No
      103: const Offset(16, 9), // Lr
    };

    final position = positions[atomicNumber] ?? const Offset(0, 0);
    return Offset(position.dx * 60.0, position.dy * 60.0);
  }

  // Element Renklendirme
  Color getElementColor(PeriodicElement element) {
    if (_state.selectedGroup != null && element.group == _state.selectedGroup) {
      return Colors.blue;
    }
    if (_state.selectedPeriod != null &&
        element.period == _state.selectedPeriod) {
      return Colors.green;
    }
    if (element == _state.selectedElement) {
      return Colors.orange;
    }
    return element.colors?.toColor() ?? Colors.grey;
  }
}

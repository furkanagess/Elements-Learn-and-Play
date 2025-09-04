import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:elements_app/feature/service/api_service.dart';
import 'package:elements_app/product/constants/api_types.dart';

class PeriodicTableService {
  final ApiService _apiService;

  PeriodicTableService(this._apiService);

  Future<List<PeriodicElement>> getElements() async {
    try {
      final elements = await _apiService.fetchElements(ApiTypes.allElements);

      // UUE (119) elementini Hidrojen ile değiştir
      final correctedElements = elements.map((element) {
        if (element.number == 119) {
          return element.copyWith(
            number: 1,
            symbol: 'H',
            enName: 'Hydrogen',
            trName: 'Hidrojen',
            enCategory: 'Reactive nonmetal',
            trCategory: 'Reaktif ametal',
            block: 's',
            period: '1',
            group: '1',
            electronConfiguration: '1s¹',
            weight: '1.008',
          );
        }
        return element;
      }).toList();

      // Atom numarasına göre sırala
      correctedElements
          .sort((a, b) => (a.number ?? 0).compareTo(b.number ?? 0));

      return correctedElements;
    } catch (e) {
      throw Exception('Failed to load periodic table elements: $e');
    }
  }
}

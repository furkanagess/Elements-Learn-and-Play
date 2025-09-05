import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:elements_app/feature/model/info.dart';
import 'package:elements_app/product/constants/api_types.dart';
import 'package:http/http.dart' as http;

class InfoProvider extends ChangeNotifier {
  List<Info> _infoList = [];
  bool _isLoading = false;
  String? _error;

  List<Info> get infoList => _infoList;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInfoList() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(Uri.parse(ApiTypes.whatIs));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _infoList = data.map((json) => Info.fromJson(json)).toList();
      } else {
        _error = 'Failed to load info data';
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching info list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

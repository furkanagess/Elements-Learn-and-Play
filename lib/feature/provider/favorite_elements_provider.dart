import 'package:elements_app/feature/model/periodic_element.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteElementsProvider extends ChangeNotifier {
  final String _storageKey = 'favorite_elements';
  List<PeriodicElement> _favoriteElements = [];
  late SharedPreferences _prefs;

  List<PeriodicElement> get favoriteElements => _favoriteElements;

  FavoriteElementsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
  }

  void _loadFavorites() {
    final String? favoritesJson = _prefs.getString(_storageKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      _favoriteElements =
          decoded.map((item) => PeriodicElement.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final String encoded =
        jsonEncode(_favoriteElements.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }

  bool isFavorite(PeriodicElement element) {
    return _favoriteElements.any((e) => e.number == element.number);
  }

  void toggleFavorite(PeriodicElement element) {
    if (isFavorite(element)) {
      _favoriteElements.removeWhere((e) => e.number == element.number);
    } else {
      _favoriteElements.add(element);
    }
    _saveFavorites();
    notifyListeners();
  }
}

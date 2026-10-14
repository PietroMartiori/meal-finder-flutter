import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persiste somente os IDs das receitas favoritas no dispositivo.
class FavoritesService extends ChangeNotifier {
  static const _key = 'favorite_meal_ids';
  final List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);
  int get count => _ids.length;
  bool contains(String idMeal) => _ids.contains(idMeal);

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedIds = preferences.getStringList(_key) ?? const <String>[];
      _ids
        ..clear()
        ..addAll(savedIds.where((id) => id.trim().isNotEmpty).toSet());
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggle(String idMeal) async {
    if (idMeal.trim().isEmpty) return;
    if (_ids.contains(idMeal)) {
      _ids.remove(idMeal);
    } else {
      _ids.insert(0, idMeal);
    }
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_key, _ids);
  }
}

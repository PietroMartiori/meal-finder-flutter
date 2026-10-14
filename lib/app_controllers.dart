import 'package:flutter/foundation.dart';

class AppNavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void select(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}

enum MealFilterType { area, ingredient, category }

/// Permite que atalhos da Home abram a Busca com um filtro real da API.
class MealSearchRequestController extends ChangeNotifier {
  MealFilterType? _filterType;
  String? _apiValue;
  int _revision = 0;

  MealFilterType? get filterType => _filterType;
  String? get apiValue => _apiValue;
  int get revision => _revision;

  void openFilter(MealFilterType type, String apiValue) {
    _filterType = type;
    _apiValue = apiValue;
    _revision++;
    notifyListeners();
  }

  void clear() {
    _filterType = null;
    _apiValue = null;
    _revision++;
    notifyListeners();
  }
}

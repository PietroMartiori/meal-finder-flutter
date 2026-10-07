import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

/// Centraliza as requisições à API TheMealDB.
class MealService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  /// Busca receitas para preencher os destaques da primeira versão do app.
  Future<List<Meal>> getFeaturedMeals() async {
    final uri = Uri.parse('$_baseUrl/search.php?s=chicken');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw MealServiceException(
        'A API respondeu com status ${response.statusCode}.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final mealsJson = body['meals'] as List<dynamic>?;

    if (mealsJson == null) {
      return [];
    }

    return mealsJson
        .map((mealJson) => Meal.fromJson(mealJson as Map<String, dynamic>))
        .toList();
  }

}

class MealServiceException implements Exception {
  const MealServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

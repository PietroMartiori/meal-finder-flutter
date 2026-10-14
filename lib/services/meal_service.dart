import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal_detail.dart';
import '../models/meal_summary.dart';

/// Cliente tipado para os endpoints públicos da TheMealDB.
class MealService {
  MealService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1/';
  static const _timeout = Duration(seconds: 15);

  final http.Client _client;

  Future<List<MealDetail>> searchMeals(String query) async {
    if (query.trim().isEmpty) return const [];
    final json = await _get('search.php', {'s': query.trim()});
    return _meals(json).map(MealDetail.fromJson).toList();
  }

  Future<MealDetail?> getMealById(String idMeal) async {
    final json = await _get('lookup.php', {'i': idMeal});
    final meals = _meals(json);
    return meals.isEmpty ? null : MealDetail.fromJson(meals.first);
  }

  Future<MealDetail?> getRandomMeal() async {
    final json = await _get('random.php');
    final meals = _meals(json);
    return meals.isEmpty ? null : MealDetail.fromJson(meals.first);
  }

  Future<List<Category>> getCategories() async {
    final json = await _get('categories.php');
    final categories = json['categories'];
    if (categories == null) return const [];
    if (categories is! List) {
      throw const MealServiceException(
        'A resposta de categorias recebida é inválida.',
      );
    }
    return categories
        .whereType<Map>()
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<MealSummary>> filterByCategory(String category) =>
      _filter('c', category);

  Future<List<MealSummary>> filterByArea(String area) => _filter('a', area);

  Future<List<MealSummary>> filterByIngredient(String ingredient) {
    final normalized = ingredient.trim().replaceAll(RegExp(r'\s+'), '_');
    return _filter('i', normalized);
  }

  Future<List<String>> listAreas() => _list('a', 'strArea');
  Future<List<String>> listCategories() => _list('c', 'strCategory');
  Future<List<String>> listIngredients() => _list('i', 'strIngredient');

  /// Hidrata IDs de favoritos. A API não possui um endpoint de favoritos.
  Future<List<MealDetail>> getMealsByIds(Iterable<String> ids) async {
    final results = await Future.wait(ids.map(getMealById));
    return results.whereType<MealDetail>().toList();
  }

  Future<List<MealSummary>> _filter(String key, String value) async {
    if (value.trim().isEmpty) return const [];
    final json = await _get('filter.php', {key: value.trim()});
    return _meals(json).map(MealSummary.fromJson).toList();
  }

  Future<List<String>> _list(String parameter, String property) async {
    final json = await _get('list.php', {parameter: 'list'});
    return _meals(json)
        .map((item) => item[property]?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> queryParameters = const {},
  ]) async {
    final uri = Uri.parse(
      _baseUrl + path,
    ).replace(queryParameters: queryParameters);
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw MealServiceException(
          'A API respondeu com status ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const MealServiceException(
          'A resposta da API está em um formato inesperado.',
        );
      }
      return Map<String, dynamic>.from(decoded);
    } on TimeoutException {
      throw const MealServiceException(
        'A requisição demorou demais. Tente novamente.',
      );
    } on http.ClientException {
      throw const MealServiceException('Não foi possível acessar a TheMealDB.');
    } on FormatException {
      throw const MealServiceException('A resposta da API não pôde ser lida.');
    }
  }

  List<Map<String, dynamic>> _meals(Map<String, dynamic> json) {
    final meals = json['meals'];
    if (meals == null) return const [];
    if (meals is! List) {
      throw const MealServiceException(
        'A lista de receitas recebida é inválida.',
      );
    }
    return meals
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}

class MealServiceException implements Exception {
  const MealServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}

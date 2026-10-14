import 'meal_summary.dart';

class MealIngredient {
  const MealIngredient({required this.name, required this.measure});

  final String name;
  final String measure;
}

/// Receita completa, retornada por search, lookup e random da TheMealDB.
class MealDetail extends MealSummary {
  const MealDetail({
    required super.idMeal,
    required super.strMeal,
    required super.strMealThumb,
    required super.strCategory,
    required super.strArea,
    required this.strInstructions,
    required this.strYoutube,
    required this.ingredients,
  });

  final String strInstructions;
  final String strYoutube;
  final List<MealIngredient> ingredients;

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];

    for (var index = 1; index <= 20; index++) {
      final ingredient = _text(json['strIngredient$index']);
      if (ingredient.isEmpty) {
        continue;
      }
      ingredients.add(
        MealIngredient(
          name: ingredient,
          measure: _text(json['strMeasure$index']),
        ),
      );
    }

    return MealDetail(
      idMeal: _text(json['idMeal']),
      strMeal: _text(json['strMeal'], fallback: 'Receita sem nome'),
      strMealThumb: _text(json['strMealThumb']),
      strCategory: _text(json['strCategory']),
      strArea: _text(json['strArea']),
      strInstructions: _text(json['strInstructions']),
      strYoutube: _text(json['strYoutube']),
      ingredients: List.unmodifiable(ingredients),
    );
  }

  /// Converte as instruções textuais da API em etapas legíveis.
  List<String> get preparationSteps {
    final lines = strInstructions
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.length > 1) {
      return lines;
    }

    return strInstructions
        .split(RegExp(r'(?<=[.!?])\s+(?=[A-ZÀ-Ú0-9])'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

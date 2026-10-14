/// Dados que TheMealDB devolve em buscas e filtros.
class MealSummary {
  const MealSummary({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    this.strCategory = '',
    this.strArea = '',
  });

  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String strCategory;
  final String strArea;

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      idMeal: _text(json['idMeal']),
      strMeal: _text(json['strMeal'], fallback: 'Receita sem nome'),
      strMealThumb: _text(json['strMealThumb']),
      strCategory: _text(json['strCategory']),
      strArea: _text(json['strArea']),
    );
  }

  static String _text(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }
}

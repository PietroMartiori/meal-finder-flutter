import 'meal_summary.dart';

/// Conteúdo local do app para os campos que não existem na TheMealDB.
class EditorialMetadata {
  const EditorialMetadata({
    required this.rating,
    required this.preparationMinutes,
    required this.difficulty,
    required this.portions,
  });

  final double rating;
  final int preparationMinutes;
  final String difficulty;
  final int portions;

  factory EditorialMetadata.forMeal(MealSummary meal) {
    var hash = 2166136261;
    for (final codeUnit in meal.idMeal.codeUnits) {
      hash = (hash ^ codeUnit) * 16777619;
      hash &= 0x7fffffff;
    }

    return EditorialMetadata(
      rating: 4.2 + (hash % 8) / 10,
      preparationMinutes: 15 + (hash % 6) * 5,
      difficulty: const ['Fácil', 'Média', 'Fácil'][hash % 3],
      portions: 2 + hash % 3,
    );
  }

  static String shortDescription(MealSummary meal) {
    final category = meal.strCategory.isEmpty
        ? 'prato especial'
        : meal.strCategory.toLowerCase();
    final area = meal.strArea.isEmpty ? '' : ' com inspiração ${meal.strArea}';
    return 'Uma sugestão de $category$area para tornar sua próxima refeição mais gostosa.';
  }
}

/// Valores de interface em PT-BR sem alterar o valor enviado à API.
class ApiValueMapper {
  ApiValueMapper._();

  static const quickMealsCategory = 'Chicken';
  static const dinnerCategory = 'Beef';

  static const _labels = <String, String>{
    'Beef': 'Carne',
    'Breakfast': 'Café da manhã',
    'Chicken': 'Frango',
    'Dessert': 'Sobremesas',
    'Goat': 'Cabra',
    'Lamb': 'Cordeiro',
    'Miscellaneous': 'Diversos',
    'Pasta': 'Massas',
    'Pork': 'Porco',
    'Seafood': 'Frutos do mar',
    'Side': 'Acompanhamentos',
    'Starter': 'Entradas',
    'Vegan': 'Vegano',
    'Vegetarian': 'Vegetariano',
    'American': 'Norte-americana',
    'British': 'Britânica',
    'Canadian': 'Canadense',
    'Chinese': 'Chinesa',
    'French': 'Francesa',
    'Greek': 'Grega',
    'Indian': 'Indiana',
    'Italian': 'Italiana',
    'Japanese': 'Japonesa',
    'Mexican': 'Mexicana',
    'Portuguese': 'Portuguesa',
    'Spanish': 'Espanhola',
    'Thai': 'Tailandesa',
    'Turkish': 'Turca',
  };

  static String label(String apiValue) => _labels[apiValue] ?? apiValue;

  static String searchTermForApi(String visibleTerm) {
    const translations = <String, String>{
      'frango': 'chicken',
      'carne': 'beef',
      'sobremesa': 'dessert',
      'sobremesas': 'dessert',
      'frutos do mar': 'seafood',
      'massa': 'pasta',
      'massas': 'pasta',
    };
    return translations[visibleTerm.trim().toLowerCase()] ?? visibleTerm.trim();
  }
}

/// Representa os campos de uma receita usados nesta primeira tela.
class Meal {
  const Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.area,
  });

  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final String area;

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      // As chaves abaixo são retornadas pelo JSON da TheMealDB.
      id: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? 'Receita sem nome',
      imageUrl: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String? ?? 'Sem categoria',
      area: json['strArea'] as String? ?? 'Origem não informada',
    );
  }
}

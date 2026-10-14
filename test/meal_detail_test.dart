import 'package:flutter_test/flutter_test.dart';
import 'package:meal_finder/models/meal_detail.dart';

void main() {
  group('MealDetail.fromJson', () {
    test('pareia ingredientes e medidas, ignorando ingredientes vazios', () {
      final meal = MealDetail.fromJson({
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strMealThumb': 'https://example.test/chicken.jpg',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions': 'Misture tudo.\nAsse até dourar.',
        'strYoutube': null,
        'strIngredient1': 'Chicken Breasts',
        'strMeasure1': '3',
        'strIngredient2': '  Rice  ',
        'strMeasure2': ' ',
        'strIngredient3': '  ',
        'strMeasure3': '1 cup',
        'strIngredient4': null,
      });

      expect(meal.idMeal, '52772');
      expect(meal.ingredients, hasLength(2));
      expect(meal.ingredients[0].name, 'Chicken Breasts');
      expect(meal.ingredients[0].measure, '3');
      expect(meal.ingredients[1].name, 'Rice');
      expect(meal.ingredients[1].measure, isEmpty);
      expect(meal.preparationSteps, ['Misture tudo.', 'Asse até dourar.']);
      expect(meal.strYoutube, isEmpty);
    });
  });
}

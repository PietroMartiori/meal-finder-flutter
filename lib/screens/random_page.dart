import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controllers.dart';
import '../models/editorial_metadata.dart';
import '../models/meal_detail.dart';
import '../services/favorites_service.dart';
import '../services/meal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_states.dart';
import '../widgets/floating_navigation_bar.dart';
import '../widgets/meal_card.dart';
import 'recipe_detail_page.dart';

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  final MealService _mealService = MealService();
  late Future<MealDetail?> _meal;

  @override
  void initState() {
    super.initState();
    _meal = _mealService.getRandomMeal();
  }

  void _drawAgain() {
    final nextMeal = _mealService.getRandomMeal();
    setState(() => _meal = nextMeal);
  }

  void _selectNavigation(int index) {
    context.read<AppNavigationController>().select(index);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: FloatingNavigationBar(
      selectedIndex: 0,
      onSelected: _selectNavigation,
    ),
    body: SafeArea(
      bottom: false,
      child: FutureBuilder<MealDetail?>(
        future: _meal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingState(
              message: 'Sorteando uma receita deliciosa...',
            );
          }
          if (snapshot.hasError) return ErrorState(onRetry: _drawAgain);
          final meal = snapshot.data;
          if (meal == null) {
            return EmptyState(
              message: 'Nenhuma surpresa foi encontrada agora.',
              icon: Icons.casino_outlined,
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 108),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Descobrir',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppTheme.softSurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shuffle_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(27),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Me Surpreenda!',
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Receita do Dia',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Saia da sua rotina. Algo delicioso está esperando por você.',
                        style: TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 16,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _RandomMealCard(
                  meal: meal,
                  onOpen: () => _openDetail(meal.idMeal),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _drawAgain,
                  icon: const Icon(Icons.shuffle_rounded),
                  label: const Text('Obter Receita Aleatória'),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Uma nova ideia a cada vez.',
                    style: TextStyle(color: AppTheme.mutedText),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  void _openDetail(String idMeal) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => RecipeDetailPage(idMeal: idMeal)),
  );
}

class _RandomMealCard extends StatelessWidget {
  const _RandomMealCard({required this.meal, required this.onOpen});
  final MealDetail meal;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final metadata = EditorialMetadata.forMeal(meal);
    final favorite = context.select<FavoritesService, bool>(
      (service) => service.contains(meal.idMeal),
    );
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 290,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MealImage(imageUrl: meal.strMealThumb),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: const Text(
                            'ESCOLHA DO DIA',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: () async => context
                                .read<FavoritesService>()
                                .toggle(meal.idMeal),
                            icon: Icon(
                              favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: favorite ? AppTheme.primary : AppTheme.ink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.strMeal,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${ApiValueMapper.label(meal.strCategory)} | ${ApiValueMapper.label(meal.strArea)}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 17),
                      Text(
                        '★ ${metadata.rating.toStringAsFixed(1)}   ·   ${metadata.preparationMinutes} min   ·   ${metadata.difficulty}',
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        EditorialMetadata.shortDescription(meal),
                        style: const TextStyle(
                          color: AppTheme.mutedText,
                          fontSize: 16,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton.icon(
                        onPressed: onOpen,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'Ver receita completa',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

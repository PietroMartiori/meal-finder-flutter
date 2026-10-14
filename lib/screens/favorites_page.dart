import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/meal_detail.dart';
import '../services/favorites_service.dart';
import '../services/meal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_states.dart';
import '../widgets/meal_card.dart';
import 'recipe_detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final MealService _mealService = MealService();
  Future<List<MealDetail>>? _favorites;
  String _idsKey = '';

  void _reload(List<String> ids) {
    final nextFavorites = _mealService.getMealsByIds(ids);
    setState(() => _favorites = nextFavorites);
  }

  @override
  Widget build(BuildContext context) {
    final ids = context.watch<FavoritesService>().ids;
    final idsKey = ids.join(',');
    if (idsKey != _idsKey) {
      _idsKey = idsKey;
      _favorites = ids.isEmpty ? null : _mealService.getMealsByIds(ids);
    }

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Receitas Favoritas',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(Icons.more_horiz_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sua pequena coleção de coisas deliciosas. Salvas para quando a vontade bater.',
              style: TextStyle(
                color: AppTheme.mutedText,
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 27),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Todas salvas · ${ids.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Chip(label: Text('Recentes')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildContent(ids)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<String> ids) {
    if (ids.isEmpty) {
      return const EmptyState(
        message:
            'Você ainda não salvou receitas. Toque no coração de um prato para guardar aqui.',
        icon: Icons.favorite_border_rounded,
      );
    }
    return FutureBuilder<List<MealDetail>>(
      future: _favorites,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState(message: 'Carregando seus favoritos...');
        }
        if (snapshot.hasError) {
          return ErrorState(
            onRetry: () => _reload(ids),
            message: 'Não foi possível carregar seus favoritos.',
          );
        }
        final meals = snapshot.data ?? const <MealDetail>[];
        if (meals.isEmpty) {
          return const EmptyState(
            message: 'Essas receitas não estão mais disponíveis na API.',
            icon: Icons.heart_broken_outlined,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 110),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
            childAspectRatio: .68,
          ),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            return MealCard(
              meal: meal,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RecipeDetailPage(idMeal: meal.idMeal),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

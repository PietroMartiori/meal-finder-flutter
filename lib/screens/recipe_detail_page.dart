import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_controllers.dart';
import '../models/editorial_metadata.dart';
import '../models/meal_detail.dart';
import '../services/favorites_service.dart';
import '../services/meal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_states.dart';
import '../widgets/floating_navigation_bar.dart';
import '../widgets/meal_card.dart';

class RecipeDetailPage extends StatefulWidget {
  const RecipeDetailPage({super.key, required this.idMeal});
  final String idMeal;

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final MealService _mealService = MealService();
  late Future<MealDetail?> _meal;
  bool _showFullDescription = false;
  bool _showIngredients = true;

  @override
  void initState() {
    super.initState();
    _meal = _mealService.getMealById(widget.idMeal);
  }

  void _retry() {
    final nextMeal = _mealService.getMealById(widget.idMeal);
    setState(() => _meal = nextMeal);
  }

  void _selectNavigation(int index) {
    context.read<AppNavigationController>().select(index);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context
        .watch<AppNavigationController>()
        .selectedIndex;
    return Scaffold(
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: selectedIndex,
        onSelected: _selectNavigation,
      ),
      body: FutureBuilder<MealDetail?>(
        future: _meal,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SafeArea(
              child: LoadingState(message: 'Carregando todos os detalhes...'),
            );
          }
          if (snapshot.hasError) {
            return SafeArea(child: ErrorState(onRetry: _retry));
          }
          final meal = snapshot.data;
          if (meal == null) {
            return const SafeArea(
              child: EmptyState(
                message: 'Não encontramos esta receita.',
                icon: Icons.no_meals_rounded,
              ),
            );
          }
          return _DetailContent(
            meal: meal,
            showFullDescription: _showFullDescription,
            showIngredients: _showIngredients,
            onToggleDescription: () =>
                setState(() => _showFullDescription = !_showFullDescription),
            onToggleIngredients: () =>
                setState(() => _showIngredients = !_showIngredients),
            onRetry: _retry,
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.meal,
    required this.showFullDescription,
    required this.showIngredients,
    required this.onToggleDescription,
    required this.onToggleIngredients,
    required this.onRetry,
  });

  final MealDetail meal;
  final bool showFullDescription;
  final bool showIngredients;
  final VoidCallback onToggleDescription;
  final VoidCallback onToggleIngredients;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final metadata = EditorialMetadata.forMeal(meal);
    final isFavorite = context.select<FavoritesService, bool>(
      (service) => service.contains(meal.idMeal),
    );
    final details = EditorialMetadata.shortDescription(meal);
    final fullDescription = meal.strInstructions.isEmpty
        ? details
        : '$details\n\n${meal.strInstructions}';
    final videoUri = _validVideoUri(meal.strYoutube);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 324,
          pinned: true,
          stretch: true,
          backgroundColor: AppTheme.ink,
          leadingWidth: 68,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _CircleButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          actions: [
            _CircleButton(
              icon: isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: isFavorite ? AppTheme.primary : AppTheme.ink,
              onPressed: () async =>
                  context.read<FavoritesService>().toggle(meal.idMeal),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _CircleButton(
                icon: Icons.share_outlined,
                onPressed: () => _copyShareLink(context, meal),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                MealImage(imageUrl: meal.strMealThumb),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [Color(0x55000000), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -22),
            child: Container(
              padding: const EdgeInsets.fromLTRB(27, 28, 27, 38),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.strMeal,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Wrap(
                    spacing: 18,
                    runSpacing: 9,
                    children: [
                      _InfoMetric(
                        icon: Icons.star_rounded,
                        text: metadata.rating.toStringAsFixed(1),
                        color: AppTheme.primary,
                      ),
                      _InfoMetric(
                        icon: Icons.schedule_rounded,
                        text: '${metadata.preparationMinutes} min',
                      ),
                      _InfoMetric(
                        icon: Icons.workspace_premium_outlined,
                        text: metadata.difficulty,
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softSurface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${ApiValueMapper.label(meal.strCategory)} | ${ApiValueMapper.label(meal.strArea)}',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 31),
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    showFullDescription ? fullDescription : details,
                    maxLines: showFullDescription ? null : 3,
                    overflow: showFullDescription
                        ? null
                        : TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontSize: 15.5,
                      height: 1.5,
                    ),
                  ),
                  if (fullDescription.length > details.length)
                    TextButton(
                      onPressed: onToggleDescription,
                      child: Text(
                        showFullDescription ? 'Mostrar menos' : 'Mostrar mais',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: onToggleIngredients,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ingredientes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Icon(
                          showIngredients
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.mutedText,
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 180),
                    crossFadeState: showIngredients
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 13),
                      child: _Ingredients(
                        ingredients: meal.ingredients,
                        portions: metadata.portions,
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Como Preparar',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 18),
                  if (meal.preparationSteps.isEmpty)
                    const Text(
                      'O modo de preparo não foi informado para esta receita.',
                      style: TextStyle(color: AppTheme.mutedText),
                    )
                  else
                    ...List.generate(
                      meal.preparationSteps.length,
                      (index) => _PreparationStep(
                        index: index + 1,
                        text: meal.preparationSteps[index],
                      ),
                    ),
                  if (videoUri != null) ...[
                    const SizedBox(height: 22),
                    _VideoCard(onTap: () => _openVideo(context, videoUri)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Uri? _validVideoUri(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            uri.host.isNotEmpty
        ? uri
        : null;
  }

  static Future<void> _openVideo(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o vídeo agora.')),
      );
    }
  }

  static Future<void> _copyShareLink(
    BuildContext context,
    MealDetail meal,
  ) async {
    final link =
        _validVideoUri(meal.strYoutube)?.toString() ??
        'Receita: ${meal.strMeal}';
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Link da receita copiado!')));
    }
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = AppTheme.ink,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor),
    ),
  );
}

class _InfoMetric extends StatelessWidget {
  const _InfoMetric({
    required this.icon,
    required this.text,
    this.color = AppTheme.mutedText,
  });
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 5),
      Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class _Ingredients extends StatelessWidget {
  const _Ingredients({required this.ingredients, required this.portions});
  final List<MealIngredient> ingredients;
  final int portions;

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) {
      return const Text(
        'Ingredientes não informados.',
        style: TextStyle(color: AppTheme.mutedText),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARA $portions PORÇÕES',
          style: const TextStyle(
            color: AppTheme.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        ...List.generate(ingredients.length, (index) {
          final item = ingredients[index];
          final label = item.measure.isEmpty
              ? item.name
              : '${item.name} — ${item.measure}';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.line)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: AppTheme.primary, size: 6),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 14.5)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PreparationStep extends StatelessWidget {
  const _PreparationStep({required this.index, required this.text});
  final int index;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppTheme.softSurface,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontSize: 14.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.play_arrow_rounded, color: Colors.white),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assista ao Tutorial em Vídeo',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  'Acompanhe passo a passo, do preparo ao prato',
                  style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.north_east_rounded, color: AppTheme.primary),
        ],
      ),
    ),
  );
}

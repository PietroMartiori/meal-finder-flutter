import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controllers.dart';
import '../models/category.dart';
import '../models/editorial_metadata.dart';
import '../models/meal_detail.dart';
import '../services/meal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_states.dart';
import '../widgets/meal_card.dart';
import 'random_page.dart';
import 'recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealService _mealService = MealService();
  late Future<_HomeData> _homeData;

  @override
  void initState() {
    super.initState();
    _homeData = _load();
  }

  Future<_HomeData> _load() async {
    final values = await Future.wait<Object>([
      _mealService.searchMeals('chicken'),
      _mealService.getCategories(),
    ]);
    return _HomeData(
      meals: values[0] as List<MealDetail>,
      categories: values[1] as List<Category>,
    );
  }

  void _retry() {
    final nextData = _load();
    setState(() => _homeData = nextData);
  }

  void _openSearch([MealFilterType? type, String? apiValue]) {
    if (type != null && apiValue != null) {
      context.read<MealSearchRequestController>().openFilter(type, apiValue);
    } else {
      context.read<MealSearchRequestController>().clear();
    }
    context.read<AppNavigationController>().select(1);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_HomeData>(
    future: _homeData,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LoadingState();
      }
      if (snapshot.hasError) {
        return ErrorState(onRetry: _retry);
      }
      final data = snapshot.data;
      if (data == null || data.meals.isEmpty) {
        return const EmptyState(
          message:
              'Nenhuma receita foi encontrada agora. Atualize e tente de novo.',
        );
      }
      return RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async => _retry(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _HomeHeader(
                  onSearch: _openSearch,
                  onDiscover: _openDiscover,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _CategoryChips(
                  availableCategories: data.categories
                      .map((item) => item.strCategory)
                      .toSet(),
                  onSelected: _openSearch,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(
                  title: 'Populares hoje',
                  onTap: () => _openSearch(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 242,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: data.meals.take(5).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => SizedBox(
                    width: 228,
                    child: MealCard(
                      meal: data.meals[index],
                      onTap: () => _openDetail(data.meals[index].idMeal),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionTitle(
                  title: 'Destaque da semana',
                  onTap: () => _openSearch(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 108),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 14,
                  childAspectRatio: .69,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final meal = data.meals[index % data.meals.length];
                  return MealCard(
                    meal: meal,
                    compact: true,
                    onTap: () => _openDetail(meal.idMeal),
                  );
                }, childCount: data.meals.length.clamp(4, 8)),
              ),
            ),
          ],
        ),
      );
    },
  );

  void _openDetail(String idMeal) => Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => RecipeDetailPage(idMeal: idMeal)),
  );

  void _openDiscover() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const RandomPage()));
}

class _HomeData {
  const _HomeData({required this.meals, required this.categories});
  final List<MealDetail> meals;
  final List<Category> categories;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearch, required this.onDiscover});
  final VoidCallback onSearch;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFFFE8DE),
            child: Icon(
              Icons.person_rounded,
              color: AppTheme.primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, Alex',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 2),
                Text(
                  'Vamos encontrar algo delicioso',
                  style: TextStyle(color: AppTheme.mutedText, fontSize: 13.5),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 25),
      InkWell(
        onTap: onSearch,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 59,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, size: 26),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Encontrar pratos',
                  style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
                ),
              ),
              Icon(Icons.tune_rounded),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      InkWell(
        onTap: onDiscover,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(19, 16, 18, 16),
          decoration: BoxDecoration(
            color: AppTheme.softSurface,
            border: Border.all(color: const Color(0xFFFFD2C3)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descobrir',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Deixe o acaso escolher sua próxima receita.',
                      style: TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Explorar',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 22),
    ],
  );
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.availableCategories,
    required this.onSelected,
  });
  final Set<String> availableCategories;
  final void Function(MealFilterType?, String?) onSelected;

  @override
  Widget build(BuildContext context) {
    final chips =
        <({String label, String? value})>[
              (label: 'Todos', value: null),
              (
                label: 'Refeições rápidas',
                value: ApiValueMapper.quickMealsCategory,
              ),
              (label: 'Jantar', value: ApiValueMapper.dinnerCategory),
              (label: 'Sobremesas', value: 'Dessert'),
              (label: 'Frutos do mar', value: 'Seafood'),
              (label: 'Carne', value: 'Beef'),
            ]
            .where(
              (chip) =>
                  chip.value == null ||
                  availableCategories.contains(chip.value),
            )
            .toList();

    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: List.generate(chips.length, (index) {
        final chip = chips[index];
        final selected = index == 0;
        return InkWell(
          onTap: () => onSelected(
            chip.value == null ? null : MealFilterType.category,
            chip.value,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.white,
              border: Border.all(
                color: selected ? AppTheme.primary : AppTheme.line,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              chip.label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.ink,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text(
            'Ver tudo',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/meal_service.dart';
import '../theme/app_theme.dart';
import '../widgets/meal_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MealService _mealService = MealService();
  late Future<List<Meal>> _featuredMeals;

  @override
  void initState() {
    super.initState();
    _featuredMeals = _mealService.getFeaturedMeals();
  }

  Future<void> _refreshMeals() async {
    final request = _mealService.getFeaturedMeals();
    setState(() => _featuredMeals = request);
    await request;
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const _BottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Meal>>(
          future: _featuredMeals,
          builder: (context, snapshot) {
            return RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _refreshMeals,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    sliver: SliverToBoxAdapter(child: _buildIntro(context)),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _LoadingState(),
                    )
                  else if (snapshot.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _ErrorState(onTryAgain: _refreshMeals),
                    )
                  else if (!snapshot.hasData || snapshot.data!.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(),
                    )
                  else
                    ..._buildRecipeSections(snapshot.data!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildRecipeSections(List<Meal> meals) {
    final popularMeals = meals.take(4).toList();
    final weeklyMeals = meals.length > 4 ? meals.skip(4).toList() : meals;

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        sliver: SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Populares hoje',
            onTap: () => _showComingSoon('Em breve, você poderá ver todos os pratos.'),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 237,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            scrollDirection: Axis.horizontal,
            itemCount: popularMeals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) => _PopularMealCard(meal: popularMeals[index]),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
        sliver: SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Destaque da semana',
            onTap: () => _showComingSoon('Em breve, você poderá ver todos os destaques.'),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) => MealCard(meal: weeklyMeals[index]),
            childCount: weeklyMeals.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
            childAspectRatio: .69,
          ),
        ),
      ),
    ];
  }

  Widget _buildIntro(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _ProfileAvatar(),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Olá, Alex', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text(
                    'Vamos encontrar algo delicioso',
                    style: TextStyle(color: AppTheme.mutedText, fontSize: 13.5),
                  ),
                ],
              ),
            ),
            _SquareIconButton(
              icon: Icons.tune_rounded,
              onTap: () => _showComingSoon('Os filtros serão adicionados nas próximas etapas.'),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _SearchBar(
          onTap: () => _showComingSoon('A busca por nome será adicionada nas próximas etapas.'),
        ),
        const SizedBox(height: 18),
        _DiscoverCard(
          onTap: () => _showComingSoon('A sugestão surpresa será adicionada em breve.'),
        ),
        const SizedBox(height: 22),
        const _CategoryChips(),
        const SizedBox(height: 25),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFFFFE8DE),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 29),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Icon(icon, color: AppTheme.ink),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 59,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, size: 26, color: AppTheme.ink),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Encontrar pratos',
                  style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
                ),
              ),
              Icon(Icons.tune_rounded, color: AppTheme.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.softSurface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(19, 16, 18, 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFFD2C3)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descobrir', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text(
                      'Deixe o acaso escolher sua próxima receita.',
                      style: TextStyle(color: AppTheme.mutedText, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Explorar',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Todos',
      'Refeições rápidas',
      'Jantar',
      'Sobremesas',
      'Frutos do mar',
      'Carne',
    ];

    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: [
        for (var index = 0; index < labels.length; index++)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: index == 0 ? AppTheme.primary : Colors.white,
              border: Border.all(color: index == 0 ? AppTheme.primary : AppTheme.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                color: index == 0 ? Colors.white : AppTheme.ink,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Ver tudo', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _PopularMealCard extends StatelessWidget {
  const _PopularMealCard({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(21),
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.line),
              borderRadius: BorderRadius.circular(21),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _MealImage(imageUrl: meal.imageUrl)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(13, 11, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${meal.category} · ${meal.area}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppTheme.mutedText, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Positioned(top: 10, right: 10, child: _HeartButton()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealImage extends StatelessWidget {
  const _MealImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const ColoredBox(
          color: AppTheme.softSurface,
          child: Center(
            child: Icon(Icons.restaurant_rounded, color: AppTheme.primary, size: 40),
          ),
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  const _HeartButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.favorite_border_rounded, color: AppTheme.ink, size: 19),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(27),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 9)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavigationItem(icon: Icons.home_outlined, label: 'Início', selected: true),
            _NavigationItem(icon: Icons.search_rounded, label: 'Buscar'),
            _NavigationItem(icon: Icons.favorite_border_rounded, label: 'Favoritos'),
            _NavigationItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
            _NavigationItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({required this.icon, required this.label, this.selected = false});

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : const Color(0xFF7E848B);
    return SizedBox(
      width: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 39,
            height: 35,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFECE5) : Colors.transparent,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 23, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text('Buscando receitas fresquinhas...'),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'Nenhuma receita foi encontrada no momento. Tente atualizar a tela.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onTryAgain});

  final Future<void> Function() onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.primary, size: 42),
            const SizedBox(height: 16),
            Text('Não foi possível carregar as receitas.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onTryAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

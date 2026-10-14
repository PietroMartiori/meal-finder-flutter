import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controllers.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteCount = context.watch<FavoritesService>().count;
    final hasFavorites = favoriteCount > 0;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meu perfil', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            const Text(
              'Acompanhe as receitas que você salvou.',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(27),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: AppTheme.softSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '$favoriteCount ${favoriteCount == 1 ? 'receita salva' : 'receitas salvas'}',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasFavorites
                        ? 'Sua coleção está guardada neste dispositivo.'
                        : 'Salve receitas para montar sua coleção.',
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context
                          .read<AppNavigationController>()
                          .select(hasFavorites ? 2 : 0),
                      icon: const Icon(Icons.favorite_border_rounded),
                      label: Text(
                        hasFavorites
                            ? 'Ver favoritos'
                            : 'Explorar receitas',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Sobre o MealFinder',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Receitas, ingredientes e instruções são consultados na TheMealDB. Seus favoritos ficam somente neste dispositivo.',
              style: TextStyle(
                color: AppTheme.mutedText,
                fontSize: 15,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

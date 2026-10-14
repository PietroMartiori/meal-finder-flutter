import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/editorial_metadata.dart';
import '../models/meal_summary.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.compact = false,
  });

  final MealSummary meal;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesService, bool>(
      (service) => service.contains(meal.idMeal),
    );
    final editorial = EditorialMetadata.forMeal(meal);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(compact ? 18 : 22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(compact ? 18 : 22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(compact ? 18 : 22),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MealImage(
                        key: ValueKey(meal.idMeal),
                        imageUrl: meal.strMealThumb,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 12 : 14,
                        11,
                        12,
                        compact ? 11 : 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            meal.strMeal,
                            maxLines: compact ? 2 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: compact ? 13.5 : 15,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 7),
                          if (meal.strArea.isNotEmpty ||
                              meal.strCategory.isNotEmpty)
                            Text(
                              _mealSubtitle(meal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.mutedText,
                                fontSize: 11.5,
                              ),
                            )
                          else if (!compact)
                            Text(
                              '★ ${editorial.rating.toStringAsFixed(1)}  ·  ${editorial.preparationMinutes} min',
                              style: const TextStyle(
                                color: AppTheme.mutedText,
                                fontSize: 11.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: _FavoriteButton(
                    mealId: meal.idMeal,
                    isFavorite: isFavorite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _mealSubtitle(MealSummary item) {
    final labels = <String>[
      if (item.strCategory.isNotEmpty) ApiValueMapper.label(item.strCategory),
      if (item.strArea.isNotEmpty) ApiValueMapper.label(item.strArea),
    ];
    return labels.join(' · ');
  }
}

class MealImage extends StatelessWidget {
  const MealImage({super.key, required this.imageUrl, this.borderRadius});

  final String imageUrl;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => const ColoredBox(
      color: AppTheme.softSurface,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppTheme.primary,
          size: 38,
        ),
      ),
    );

    final image = imageUrl.trim().isEmpty
        ? fallback()
        : Image.network(
            _thumbnailUrl(imageUrl),
            key: ValueKey(_thumbnailUrl(imageUrl)),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.medium,
            frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return const ColoredBox(
                color: Color(0xFFF0F1F2),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            errorBuilder: (_, _, _) => fallback(),
          );
    return borderRadius == null
        ? image
        : ClipRRect(borderRadius: borderRadius!, child: image);
  }

  /// A TheMealDB disponibiliza imagens de tamanho reduzido no mesmo endereço.
  /// Assim evitamos decodificar os arquivos grandes repetidamente ao voltar de
  /// uma página externa ou ao sortear outra receita.
  static String _thumbnailUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.host.endsWith('themealdb.com')) return value.trim();
    if (uri.path.endsWith('/small') ||
        uri.path.endsWith('/medium') ||
        uri.path.endsWith('/large')) {
      return uri.toString();
    }
    return uri.replace(path: '${uri.path}/medium').toString();
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.mealId, required this.isFavorite});

  final String mealId;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: isFavorite
            ? 'Remover dos favoritos'
            : 'Adicionar aos favoritos',
        onPressed: () async => context.read<FavoritesService>().toggle(mealId),
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppTheme.primary : AppTheme.ink,
          size: 21,
        ),
      ),
    );
  }
}

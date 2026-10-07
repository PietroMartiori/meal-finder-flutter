import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../theme/app_theme.dart';

/// Cartão compacto usado na grade de destaques da Home.
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SizedBox.expand(
                        child: Image.network(
                          meal.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const ColoredBox(
                            color: AppTheme.softSurface,
                            child: Center(
                              child: Icon(Icons.restaurant_rounded, color: AppTheme.primary, size: 36),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(11, 10, 11, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              height: 1.13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${meal.area} · ${meal.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.mutedText, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border_rounded, color: AppTheme.ink, size: 18),
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

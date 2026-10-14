import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FloatingNavigationBar extends StatelessWidget {
  const FloatingNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Início'),
    (icon: Icons.search_rounded, label: 'Buscar'),
    (icon: Icons.favorite_border_rounded, label: 'Favoritos'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Chat'),
    (icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Container(
      height: 76,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(27),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = index == selectedIndex;
          final color = isSelected ? AppTheme.primary : const Color(0xFF7E848B);
          return InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFECE5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(item.icon, size: 23, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    ),
  );
}

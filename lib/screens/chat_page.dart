import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: AppTheme.softSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppTheme.primary,
                size: 39,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Chat em breve',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 9),
            const Text(
              'Estamos preparando um espaço para trocar ideias e receitas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedText, height: 1.45),
            ),
          ],
        ),
      ),
    ),
  );
}

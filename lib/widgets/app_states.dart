import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message = 'Buscando receitas fresquinhas...',
  });
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppTheme.primary),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.search_off_rounded,
  });
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primary, size: 44),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.onRetry,
    this.message = 'Não foi possível carregar as receitas.',
  });
  final VoidCallback onRetry;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.primary, size: 44),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Verifique sua conexão e tente novamente.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}

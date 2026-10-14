import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

/// Perfil ilustrativo: seus dados e preferências pertencem somente ao dispositivo.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteCount = context.watch<FavoritesService>().count;
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
              'Seu gosto, suas receitas, do seu jeito.',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 16),
            ),
            const SizedBox(height: 30),
            _ProfileSummary(
              onEdit: () => _showLocalNotice(
                context,
                'As informações de perfil são mantidas neste dispositivo.',
              ),
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meus favoritos · $favoriteCount',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => _showLocalNotice(
                    context,
                    'Abra a aba Favoritos para ver suas receitas salvas.',
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SavedMealPreview(count: favoriteCount),
            const SizedBox(height: 12),
            const Text(
              'Sua coleção, guardada neste dispositivo.',
              style: TextStyle(color: AppTheme.mutedText),
            ),
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Preferências culinárias',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () => _showLocalNotice(
                    context,
                    'Preferências culinárias locais em breve.',
                  ),
                  child: const Text('Editar'),
                ),
              ],
            ),
            _PreferencesCard(
              onTap: () => _showLocalNotice(
                context,
                'Nenhuma restrição alimentar foi selecionada.',
              ),
            ),
            const SizedBox(height: 34),
            Text(
              'Configurações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            _SettingsCard(
              onTap: () => _showLocalNotice(
                context,
                'Esta configuração é local e não envia dados para a API.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showLocalNotice(BuildContext context, String message) =>
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.onEdit});
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
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
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: AppTheme.softSurface,
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.primary,
                size: 48,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alex',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Sempre em busca de algo delicioso.',
                    style: TextStyle(color: AppTheme.mutedText, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onEdit,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.softSurface,
              foregroundColor: AppTheme.primary,
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar perfil'),
          ),
        ),
      ],
    ),
  );
}

class _SavedMealPreview extends StatelessWidget {
  const _SavedMealPreview({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final cards = count == 0 ? 3 : count.clamp(1, 6);
    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 112,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.line),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.softSurface,
                child: Icon(Icons.restaurant_rounded, color: AppTheme.primary),
              ),
              Spacer(),
              Text(
                'Receita salva',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cozinhas que você gosta',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: const [
            Chip(
              label: Text('Italiana'),
              backgroundColor: AppTheme.softSurface,
            ),
            Chip(
              label: Text('Japonesa'),
              backgroundColor: AppTheme.softSurface,
            ),
            Chip(
              label: Text('Mexicana'),
              backgroundColor: AppTheme.softSurface,
            ),
          ],
        ),
        const Divider(height: 34),
        InkWell(
          onTap: onTap,
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restrições alimentares',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Nenhuma selecionada',
                      style: TextStyle(color: AppTheme.mutedText),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.mutedText),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Preferências ilustrativas, salvas no dispositivo.',
          style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
        ),
      ],
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(25),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        _SettingRow(
          icon: Icons.language_rounded,
          title: 'Idioma',
          subtitle: 'Português (Brasil)',
          onTap: onTap,
        ),
        const Divider(indent: 72, endIndent: 24, height: 1),
        _SettingRow(
          icon: Icons.verified_user_outlined,
          title: 'Privacidade',
          subtitle: 'Seus dados e preferências locais',
          onTap: onTap,
        ),
        const Divider(indent: 72, endIndent: 24, height: 1),
        _SettingRow(
          icon: Icons.help_outline_rounded,
          title: 'Ajuda',
          subtitle: 'Dúvidas sobre o MealFinder',
          onTap: onTap,
        ),
      ],
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
    leading: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppTheme.primary),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
    subtitle: Text(subtitle),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      color: AppTheme.mutedText,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_controllers.dart';
import 'screens/favorites_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/search_page.dart';
import 'services/favorites_service.dart';
import 'theme/app_theme.dart';
import 'widgets/floating_navigation_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final favorites = FavoritesService();
  try {
    await favorites.load();
  } catch (_) {
    // O app continua funcional em memória se o armazenamento local falhar.
  }
  runApp(MealFinderApp(favorites: favorites));
}

class MealFinderApp extends StatelessWidget {
  const MealFinderApp({super.key, required this.favorites});
  final FavoritesService favorites;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: favorites),
      ChangeNotifierProvider(create: (_) => AppNavigationController()),
      ChangeNotifierProvider(create: (_) => MealSearchRequestController()),
    ],
    child: MaterialApp(
      title: 'MealFinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    ),
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context
        .watch<AppNavigationController>()
        .selectedIndex;
    const pages = [
      HomePage(),
      SearchPage(),
      FavoritesPage(),
      ProfilePage(),
    ];
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: FloatingNavigationBar(
        selectedIndex: selectedIndex,
        onSelected: context.read<AppNavigationController>().select,
      ),
    );
  }
}

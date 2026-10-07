import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MealFinderApp());
}

class MealFinderApp extends StatelessWidget {
  const MealFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealFinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}

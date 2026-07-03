import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/mock_demon_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DemonApp());
}

class DemonApp extends StatelessWidget {
  const DemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demon Board',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      home: HomeScreen(service: MockDemonService()),
    );
  }
}

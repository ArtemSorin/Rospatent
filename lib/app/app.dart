import 'package:flutter/material.dart';
import 'package:rospatent/core/theme/app_theme.dart';

import 'main_shell.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Роспатент',
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}

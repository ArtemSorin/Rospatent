import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'app/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = AppDependencies.create();

  // перенос старого избранного (id в SharedPreferences) в SQLite
  unawaited(dependencies.migrateLegacyFavorites().catchError((_) {}));

  runApp(AppScope(dependencies: dependencies, child: const App()));
}

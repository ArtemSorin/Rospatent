import 'package:flutter/widgets.dart';

import 'injection.dart';

/// Отдаёт [AppDependencies] вниз по дереву виджетов.
class AppScope extends InheritedWidget {
  final AppDependencies dependencies;

  const AppScope({super.key, required this.dependencies, required super.child});

  /// Безопасно вызывать и из initState: подписки на изменения не нужны,
  /// зависимости за время жизни приложения не меняются.
  static AppDependencies of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope не найден в дереве виджетов');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}

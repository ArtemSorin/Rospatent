import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/app.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/app/main_shell.dart';

import '../helpers/fakes.dart';
import '../helpers/pump.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(AppScope(dependencies: buildDeps(), child: const App()));
  }

  testWidgets('показывает MainShell без debug-баннера', (tester) async {
    await openApp(tester);
    expect(find.byType(MainShell), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).debugShowCheckedModeBanner, isFalse);
  });

  testWidgets('тема: поля ввода, цвет и кнопки', (tester) async {
    await openApp(tester);
    final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;

    expect(theme.colorScheme.primary, Colors.blueAccent);
    expect(theme.inputDecorationTheme.filled, isTrue);
    expect(theme.inputDecorationTheme.fillColor, Colors.grey.shade100);
    expect(theme.inputDecorationTheme.prefixIconColor, Colors.grey);

    // кнопка «Поиск» на главной растягивается по ширине и имеет высоту 50
    final size = tester.getSize(find.byType(ElevatedButton));
    expect(size.height, 50);
    expect(size.width, greaterThan(200));
  });
}

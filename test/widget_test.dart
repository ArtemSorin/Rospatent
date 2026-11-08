// Дымовой тест всего приложения. Подробные тесты лежат рядом по слоям:
// test/core, test/app, test/features/*, test/integration.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/app.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('приложение запускается на экране поиска', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AppScope(dependencies: buildDeps(), child: const App()),
    );

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Роспатент'), findsOneWidget);
    expect(find.text('Поиск по тексту патентов'), findsOneWidget);
    expect(
      find.byIcon(Icons.star_outline_rounded),
      findsOneWidget,
    ); // вкладка «Избранное»
  });
}

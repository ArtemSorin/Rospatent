import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/about/presentation/about_screen.dart';

import '../../helpers/pump.dart';

void main() {
  Future<void> openAbout(WidgetTester tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
  }

  testWidgets('показывает название и описание приложения', (tester) async {
    await openAbout(tester);
    expect(find.text('О приложении'), findsOneWidget);
    expect(find.text('Роспатент'), findsOneWidget);
    expect(find.text('Поиск патентов в базе данных Роспатента'), findsOneWidget);
    expect(find.textContaining('Это приложение помогает вам в поиске патентов'), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_outlined), findsOneWidget);
  });

  testWidgets('перечисляет основные возможности', (tester) async {
    await openAbout(tester);
    expect(find.text('Основные возможности'), findsOneWidget);
    for (final title in [
      'Поиск патентов',
      'Сохранение в избранное',
      'Детальное описание патента',
      'Уведомления',
    ]) {
      expect(find.text(title), findsOneWidget, reason: title);
    }
    for (final icon in [
      Icons.search_outlined,
      Icons.star_outline,
      Icons.description_outlined,
      Icons.notifications_active_outlined,
    ]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
  });

  testWidgets('показывает версию и год', (tester) async {
    await openAbout(tester);
    expect(find.text('Версия приложения'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('© 2025'), findsOneWidget);
  });

  testWidgets('кнопки в шапке нажимаются без ошибок', (tester) async {
    await openAbout(tester);
    await tester.tap(find.byIcon(Icons.account_circle_outlined));
    await tester.tap(find.byIcon(Icons.notifications_none));
    expect(tester.takeException(), isNull);
  });
}

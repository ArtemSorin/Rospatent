import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
import 'package:rospatent/core/theme/app_text.dart';

Future<void> pumpBar(WidgetTester tester, CustomAppBar bar) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(appBar: bar)));

void main() {
  group('CustomAppBar', () {
    testWidgets('показывает заголовок нужным стилем', (tester) async {
      await pumpBar(tester, const CustomAppBar(title: 'Заголовок'));

      final text = tester.widget<Text>(find.text('Заголовок'));
      expect(text.style!.color, AppText.h3.color);
      expect(text.style!.fontWeight, AppText.h3.fontWeight);
      expect(text.style!.fontSize, AppText.h3.fontSize);
    });

    testWidgets('значения по умолчанию: белый фон, тень 1, заголовок слева', (tester) async {
      await pumpBar(tester, const CustomAppBar(title: 'T'));

      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.backgroundColor, Colors.white);
      expect(bar.elevation, 0);
      expect(bar.centerTitle, isTrue);
      expect(bar.leading, isNull);
      expect(bar.actions, isNotNull);
    });

    testWidgets('пробрасывает centerTitle, цвет и тень', (tester) async {
      await pumpBar(
        tester,
        const CustomAppBar(
          title: 'T',
          centerTitle: true,
          backgroundColor: Colors.red,
          elevation: 4,
        ),
      );

      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.centerTitle, isTrue);
      expect(bar.backgroundColor, Colors.red);
      expect(bar.elevation, 4);
    });

    testWidgets('показывает leading и actions', (tester) async {
      await pumpBar(
        tester,
        CustomAppBar(
          title: 'T',
          leading: const Icon(Icons.menu),
          actions: const [Icon(Icons.search), Icon(Icons.share)],
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    test('высота равна kToolbarHeight', () {
      expect(const CustomAppBar(title: 'T').preferredSize, const Size.fromHeight(kToolbarHeight + 1));
    });
  });
}

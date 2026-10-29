import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/widgets/page_paginator.dart';

import '../helpers/pump.dart';

Future<void> pumpPaginator(
  WidgetTester tester, {
  int current = 0,
  int total = 20,
  bool enabled = true,
  required void Function(int) onSelected,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: PagePaginator(
          currentPage: current,
          totalPages: total,
          enabled: enabled,
          onPageSelected: onSelected,
        ),
      ),
    ),
  );
}

void main() {
  group('paginatorItems', () {
    test('нет страниц — пустой список', () {
      expect(paginatorItems(0, 0), isEmpty);
      expect(paginatorItems(0, -3), isEmpty);
    });

    test('до 7 страниц показываются все', () {
      expect(paginatorItems(0, 1), [0]);
      expect(paginatorItems(2, 5), [0, 1, 2, 3, 4]);
      expect(paginatorItems(6, 7), [0, 1, 2, 3, 4, 5, 6]);
    });

    test('в начале списка', () {
      expect(paginatorItems(0, 20), [0, 1, 2, 3, 4, null, 19]);
      expect(paginatorItems(3, 20), [0, 1, 2, 3, 4, null, 19]);
    });

    test('в середине списка', () {
      expect(paginatorItems(4, 20), [0, null, 3, 4, 5, null, 19]);
      expect(paginatorItems(10, 20), [0, null, 9, 10, 11, null, 19]);
      expect(paginatorItems(15, 20), [0, null, 14, 15, 16, null, 19]);
    });

    test('в конце списка', () {
      expect(paginatorItems(16, 20), [0, null, 15, 16, 17, 18, 19]);
      expect(paginatorItems(19, 20), [0, null, 15, 16, 17, 18, 19]);
    });

    test('границы при 8 страницах', () {
      expect(paginatorItems(3, 8), [0, 1, 2, 3, 4, null, 7]);
      expect(paginatorItems(4, 8), [0, null, 3, 4, 5, 6, 7]);
    });

    test('огромное число страниц: всегда 7 элементов', () {
      expect(paginatorItems(60000, 120000).length, 7);
    });

    test('инварианты: текущая страница присутствует, элементов не больше 7', () {
      for (final total in [1, 2, 7, 8, 9, 10, 25, 1000]) {
        for (var c = 0; c < total; c++) {
          final items = paginatorItems(c, total);
          expect(items.contains(c), isTrue, reason: 'c=$c total=$total');
          expect(items.length, lessThanOrEqualTo(7));
        }
      }
    });
  });

  group('отображение', () {
    testWidgets('при одной странице и меньше скрыт', (tester) async {
      await pumpPaginator(tester, total: 1, onSelected: (_) {});
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.text('1'), findsNothing);

      await pumpPaginator(tester, total: 0, onSelected: (_) {});
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('показывает номера и многоточие', (tester) async {
      await pumpPaginator(tester, current: 0, total: 20, onSelected: (_) {});
      for (final label in ['1', '2', '3', '4', '5', '…', '20']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('6'), findsNothing);
    });

    testWidgets('текущая страница выделена', (tester) async {
      await pumpPaginator(tester, current: 2, total: 5, onSelected: (_) {});
      final selected = tester.widget<Text>(find.text('3'));
      expect(selected.style!.color, Colors.white);
      expect(selected.style!.fontWeight, FontWeight.w700);
      final other = tester.widget<Text>(find.text('1'));
      expect(other.style!.color, Colors.black87);
      expect(other.style!.fontWeight, FontWeight.w500);
    });

    testWidgets('у стрелок есть подсказки', (tester) async {
      await pumpPaginator(tester, current: 1, total: 5, onSelected: (_) {});
      expect(find.byTooltip('Предыдущая страница'), findsOneWidget);
      expect(find.byTooltip('Следующая страница'), findsOneWidget);
    });

    testWidgets('на узком экране не переполняется', (tester) async {
      useScreen(tester, width: 320, height: 600);
      await pumpPaginator(tester, current: 60000, total: 120000, onSelected: (_) {});
      expect(tester.takeException(), isNull);
      expect(find.text('60001'), findsOneWidget);
    });
  });

  group('выбор страницы', () {
    testWidgets('нажатие на номер вызывает колбэк с индексом с нуля', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 0, total: 5, onSelected: selected.add);
      await tester.tap(find.text('3'));
      expect(selected, [2]);
    });

    testWidgets('нажатие на текущую страницу ничего не делает', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 1, total: 5, onSelected: selected.add);
      await tester.tap(find.text('2'));
      expect(selected, isEmpty);
    });

    testWidgets('стрелки листают на одну страницу', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 3, total: 10, onSelected: selected.add);
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(selected, [4, 2]);
    });

    testWidgets('на первой странице «назад» недоступна', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 0, total: 5, onSelected: selected.add);
      final back = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left));
      final forward = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(back.onPressed, isNull);
      expect(forward.onPressed, isNotNull);
      await tester.tap(find.byIcon(Icons.chevron_left));
      expect(selected, isEmpty);
    });

    testWidgets('на последней странице «вперёд» недоступна', (tester) async {
      await pumpPaginator(tester, current: 4, total: 5, onSelected: (_) {});
      final back = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left));
      final forward = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(back.onPressed, isNotNull);
      expect(forward.onPressed, isNull);
    });

    testWidgets('при enabled=false всё заблокировано', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 2, total: 20, enabled: false, onSelected: selected.add);
      await tester.tap(find.text('2'));
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.tap(find.text('…').first);
      await tester.pump();
      expect(selected, isEmpty);
      expect(find.text('Перейти на страницу'), findsNothing);
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left)).onPressed, isNull);
      expect(tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_right)).onPressed, isNull);
    });
  });

  group('диалог «Перейти на страницу»', () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.text('…').first);
      await tester.pumpAndSettle();
    }

    testWidgets('открывается по нажатию на «…» с подсказкой диапазона', (tester) async {
      await pumpPaginator(tester, current: 10, total: 20, onSelected: (_) {});
      await openDialog(tester);
      expect(find.text('Перейти на страницу'), findsOneWidget);
      expect(find.text('от 1 до 20'), findsOneWidget);
      expect(find.text('Отмена'), findsOneWidget);
      expect(find.text('Перейти'), findsOneWidget);
    });

    testWidgets('переходит на введённую страницу', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), '7');
      await tester.tap(find.text('Перейти'));
      await tester.pumpAndSettle();
      expect(selected, [6]);
      expect(find.text('Перейти на страницу'), findsNothing);
    });

    testWidgets('подтверждение клавишей на клавиатуре', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), '3');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(selected, [2]);
    });

    testWidgets('слишком большой номер ограничивается последней страницей', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), '999');
      await tester.tap(find.text('Перейти'));
      await tester.pumpAndSettle();
      expect(selected, [19]);
    });

    testWidgets('ноль и отрицательные номера ограничиваются первой страницей', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), '0');
      await tester.tap(find.text('Перейти'));
      await tester.pumpAndSettle();
      expect(selected, [0]);
    });

    testWidgets('пустой или нечисловой ввод не закрывает диалог', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.tap(find.text('Перейти'));
      await tester.pumpAndSettle();
      expect(find.text('Перейти на страницу'), findsOneWidget);
      expect(selected, isEmpty);
    });

    testWidgets('«Отмена» закрывает диалог без перехода', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(find.text('Перейти на страницу'), findsNothing);
      expect(selected, isEmpty);
    });

    testWidgets('ввод текущей страницы не вызывает колбэк', (tester) async {
      final selected = <int>[];
      await pumpPaginator(tester, current: 10, total: 20, onSelected: selected.add);
      await openDialog(tester);
      await tester.enterText(find.byType(TextField), '11');
      await tester.tap(find.text('Перейти'));
      await tester.pumpAndSettle();
      expect(selected, isEmpty);
    });
  });
}

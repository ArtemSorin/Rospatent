import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/search_results_screen.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump.dart';

void main() {
  late FakePatentRepository patents;

  Future<void> pumpHome(WidgetTester tester) async {
    useTallScreen(tester);
    patents = FakePatentRepository();
    await pumpScoped(
      tester,
      const HomePage(),
      deps: buildDeps(patents: patents),
    );
  }

  Finder field(int index) => find
      .byType(TextField)
      .at(index); // 0 текст, 1 заявка, 2 авторы, 3 патентообладатели

  MaterialLocalizations l10n(WidgetTester tester) =>
      MaterialLocalizations.of(tester.element(find.byType(DatePickerDialog)));

  /// Подтверждает открытый диалог выбора даты кнопкой «OK» (подпись берётся из локализации).
  Future<void> confirmDate(WidgetTester tester) async {
    await tester.tap(find.text(l10n(tester).okButtonLabel));
    await tester.pumpAndSettle();
  }

  /// Выбирает в открытом календаре день [label] и подтверждает.
  Future<void> pickDay(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.text(label),
      ),
    );
    await tester.pump();
    await confirmDate(tester);
  }

  testWidgets('показывает все элементы формы', (tester) async {
    await pumpHome(tester);
    expect(find.text('Роспатент'), findsOneWidget);
    expect(find.text('Поиск по тексту патентов'), findsOneWidget);
    expect(find.text('Сортировка'), findsOneWidget);
    expect(find.text('Дата публикации'), findsOneWidget);
    expect(find.text('Номер заявки'), findsOneWidget);
    expect(find.text('Найти'), findsOneWidget);
    expect(find.text('Не выбрана'), findsNWidgets(2));
  });

  testWidgets('кнопки в шапке нажимаются без ошибок', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    expect(tester.takeException(), isNull);
  });

  group('поиск', () {
    testWidgets('пустая форма: запрос по умолчанию', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('Найти'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchResultsPage), findsOneWidget);
      final q = patents.searchCalls.single.query;
      expect(q.text, '');
      expect(q.authors, isEmpty);
      expect(q.patentees, isEmpty);
      expect(q.sort, SortOrder.relevance);
      expect(q.publishedFrom, isNull);
      expect(q.publishedTo, isNull);
      expect(patents.searchCalls.single.page, 0);
    });

    testWidgets('текст, авторы и патентообладатели попадают в запрос', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.enterText(field(0), '  робот  ');
      await tester.enterText(field(2), 'Иванов И.И., Петров П.П.');
      await tester.enterText(field(3), 'ООО А; ООО Б');
      await tester.tap(find.text('Найти'));
      await tester.pumpAndSettle();

      final q = patents.searchCalls.single.query;
      expect(q.text, 'робот');
      expect(q.authors, ['Иванов И.И.', 'Петров П.П.']);
      expect(q.patentees, ['ООО А', 'ООО Б']);
    });

    testWidgets('клавиша «поиск» на клавиатуре запускает поиск', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.showKeyboard(field(0));
      await tester.enterText(field(0), 'лазер');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.byType(SearchResultsPage), findsOneWidget);
      expect(patents.searchCalls.single.query.text, 'лазер');
    });

    testWidgets('выбранная сортировка попадает в запрос', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('Публикация ↓'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Найти'));
      await tester.pumpAndSettle();

      expect(patents.searchCalls.single.query.sort, SortOrder.publicationDesc);
    });
  });

  group('даты', () {
    final today = DateTime.now();
    final todayText = DateFormat('dd.MM.yyyy').format(today);

    testWidgets('выбор даты «от» отображается в поле и уходит в запрос', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.text('Не выбрана').first);
      await tester.pumpAndSettle();
      await confirmDate(tester);

      expect(find.text(todayText), findsOneWidget);
      expect(find.text('Не выбрана'), findsOneWidget);

      await tester.tap(find.text('Найти'));
      await tester.pumpAndSettle();
      final from = patents.searchCalls.single.query.publishedFrom!;
      expect(
        [from.year, from.month, from.day],
        [today.year, today.month, today.day],
      );
      expect(patents.searchCalls.single.query.publishedTo, isNull);
    });

    testWidgets('выбор даты «до»', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('Не выбрана').last);
      await tester.pumpAndSettle();
      await confirmDate(tester);

      await tester.tap(find.text('Найти'));
      await tester.pumpAndSettle();
      final to = patents.searchCalls.single.query.publishedTo!;
      expect([to.year, to.month, to.day], [today.year, today.month, today.day]);
    });

    testWidgets('отмена выбора даты оставляет поле пустым', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('Не выбрана').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n(tester).cancelButtonLabel));
      await tester.pumpAndSettle();
      expect(find.text('Не выбрана'), findsNWidgets(2));
    });

    testWidgets('крестик сбрасывает выбранную дату', (tester) async {
      await pumpHome(tester);
      await tester.tap(find.text('Не выбрана').first);
      await tester.pumpAndSettle();
      await confirmDate(tester);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(find.text('Не выбрана'), findsNWidgets(2));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets(
      '«от» позже «до»: показывается предупреждение и поиск не запускается',
      (tester) async {
        await pumpHome(tester);

        // «от» = сегодня
        await tester.tap(find.text('Не выбрана').first);
        await tester.pumpAndSettle();
        await confirmDate(tester);

        // «до» = более ранний день
        await tester.tap(find.text('Не выбрана'));
        await tester.pumpAndSettle();
        if (today.day == 1) {
          await tester.tap(find.byTooltip(l10n(tester).previousMonthTooltip));
          await tester.pumpAndSettle();
          await pickDay(tester, '15');
        } else {
          await pickDay(tester, '1');
        }

        await tester.tap(find.text('Найти'));
        await tester.pump();

        expect(
          find.text('Дата «от» не может быть позже даты «до»'),
          findsOneWidget,
        );
        expect(find.byType(SearchResultsPage), findsNothing);
        expect(patents.searchCalls, isEmpty);
      },
    );
  });
}

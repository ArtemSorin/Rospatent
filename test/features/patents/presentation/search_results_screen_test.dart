import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/core/widgets/page_paginator.dart';
import 'package:rospatent/features/analytics/presentation/screens/analyze_screen.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/presentation/screens/patent_details_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/search_results_screen.dart';
import 'package:rospatent/features/patents/presentation/widgets/results/patent_card.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository patents;
  const query = SearchQuery(text: 'робот');

  Future<void> openResults(WidgetTester tester, {bool tall = true}) async {
    tall ? useTallScreen(tester) : useScreen(tester);
    await pumpScoped(
      tester,
      const SearchResultsPage(query: query),
      deps: buildDeps(patents: patents),
    );
  }

  setUp(() => patents = FakePatentRepository(total: 25));

  group('загрузка', () {
    testWidgets('первый запрос: индикатор, пагинатор и аналитика недоступны', (tester) async {
      final gate = Completer<SearchPage>();
      patents.searchHandler = (q, p, s) => gate.future;
      await openResults(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(PagePaginator), findsNothing);
      final analytics = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.data_usage_outlined));
      expect(analytics.onPressed, isNull);

      gate.complete(makePage());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('после загрузки видны карточки, заголовок и пагинатор', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();

      expect(find.text('Найденные патенты'), findsOneWidget);
      expect(find.byType(PatentCard), findsNWidgets(10));
      expect(find.text('Найдено патентов: 25'), findsOneWidget);
      expect(find.text('стр. 1 из 3'), findsOneWidget);
      expect(find.byType(PagePaginator), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(patents.searchCalls.single.query, same(query));
      expect(patents.searchCalls.single.page, 0);
    });

    testWidgets('одна страница: пагинатор скрыт', (tester) async {
      patents.total = 5;
      await openResults(tester);
      await tester.pumpAndSettle();
      expect(find.byType(PatentCard), findsNWidgets(5));
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.textContaining('стр.'), findsNothing);
    });

    testWidgets('пустая выдача: сообщение вместо списка', (tester) async {
      patents.total = 0;
      await openResults(tester);
      await tester.pumpAndSettle();
      expect(find.text('По вашему запросу ничего не найдено'), findsOneWidget);
      expect(find.byType(PatentCard), findsNothing);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });

  group('ошибки', () {
    testWidgets('первый запрос не удался: сообщение и повтор', (tester) async {
      patents.searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await openResults(tester);
      await tester.pumpAndSettle();

      expect(find.text('Нет соединения с сервером'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byType(PagePaginator), findsNothing);

      patents.searchHandler = null;
      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();
      expect(find.byType(PatentCard), findsNWidgets(10));
      expect(find.text('Нет соединения с сервером'), findsNothing);
    });

    testWidgets('ошибка при смене страницы: список остаётся, показан баннер', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();

      patents.searchHandler = (q, p, s) => Future.error(const ServerFailure('Ошибка сервера (500)'));
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      expect(find.text('Ошибка сервера (500)'), findsOneWidget);
      expect(anyText('Патент №1.'), findsWidgets);
      expect(find.text('стр. 1 из 3'), findsOneWidget);

      patents.searchHandler = null;
      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();
      expect(find.text('Ошибка сервера (500)'), findsNothing);
    });
  });

  group('пагинация', () {
    testWidgets('нажатие на страницу загружает её и обновляет список', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      expect(patents.searchCalls.last.page, 1);
      expect(anyText('Патент №11.'), findsWidgets);
      expect(anyText('Патент №1.'), findsNothing);
      expect(find.text('стр. 2 из 3'), findsOneWidget);
    });

    testWidgets('последняя страница содержит остаток', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      expect(find.byType(PatentCard), findsNWidgets(5));
      expect(find.text('стр. 3 из 3'), findsOneWidget);
    });

    testWidgets('пока страница грузится, видна полоска загрузки и пагинатор заблокирован', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();

      final gate = Completer<SearchPage>();
      patents.searchHandler = (q, p, s) => gate.future;
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(anyText('Патент №1.'), findsWidgets); // старый список на месте

      await tester.tap(find.text('3'));
      await tester.pump();
      expect(patents.searchCalls.length, 2); // клик по заблокированному пагинатору проигнорирован

      gate.complete(makePage(page: 1));
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(anyText('Патент №11.'), findsWidgets);
    });

    testWidgets('после перехода на страницу список прокручивается наверх', (tester) async {
      await openResults(tester, tall: false);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);
      expect(scrollable.position.pixels, greaterThan(0));

      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels, 0);
    });

    testWidgets('ошибка загрузки страницы не сбрасывает прокрутку', (tester) async {
      await openResults(tester, tall: false);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      patents.searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      expect(tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels, greaterThan(0));
    });
  });

  group('навигация', () {
    testWidgets('нажатие на карточку открывает экран патента', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();

      await tester.tap(anyText('Патент №1.').first);
      await tester.pumpAndSettle();

      expect(find.byType(PatentDetailsPage), findsOneWidget);
      expect(find.text('Выбранный патент'), findsOneWidget);
      expect(patents.detailsCalls, ['RU1001C1_20190201']);
    });

    testWidgets('кнопка аналитики открывает экран аналитики', (tester) async {
      await openResults(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.data_usage_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(AnalyzePage), findsOneWidget);
      expect(find.text('Аналитика'), findsOneWidget);
    });

    testWidgets('кнопка «назад» возвращает на предыдущий экран', (tester) async {
      useTallScreen(tester);
      await pumpPushed(tester, () => const SearchResultsPage(query: query), deps: buildDeps(patents: patents));
      await tester.pumpAndSettle();
      expect(find.text('Найденные патенты'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();
      expect(find.text('Найденные патенты'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  testWidgets('экран можно закрыть до завершения запроса', (tester) async {
    final gate = Completer<SearchPage>();
    patents.searchHandler = (q, p, s) => gate.future;
    useTallScreen(tester);
    await pumpPushed(tester, () => const SearchResultsPage(query: query), deps: buildDeps(patents: patents));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();
    gate.complete(makePage());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

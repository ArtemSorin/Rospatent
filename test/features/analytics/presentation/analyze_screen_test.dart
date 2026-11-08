import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/analytics/presentation/screens/analyze_screen.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository patents;

  Future<void> openAnalytics(
    WidgetTester tester, {
    required List<PatentSummary> items,
    required int total,
  }) async {
    useTallScreen(tester);
    await pumpScoped(
      tester,
      AnalyzePage(query: const SearchQuery(text: 'x'), pageItems: items, totalFound: total),
      deps: buildDeps(patents: patents),
    );
  }

  setUp(() => patents = FakePatentRepository());

  group('данные уже целиком на странице', () {
    testWidgets('показывает плитки, графики и рейтинги', (tester) async {
      await openAnalytics(tester, items: makePage(total: 10).items, total: 10);
      await tester.pumpAndSettle();

      expect(find.text('Аналитика'), findsOneWidget);
      expect(find.text('Анализ текущей страницы: 10 из 10 патентов'), findsOneWidget);
      expect(patents.searchCalls, isEmpty); // расширять нечего

      for (final label in ['Найдено', 'В выборке', 'Владельцев']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      for (final title in [
        'Публикации по годам',
        'Тематика (разделы МПК)',
        'Типы документов',
        'Топ правообладателей',
        'Топ авторов',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.byType(BarChart), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('G — Физика'), findsOneWidget);
      expect(find.text('10 · 100%'), findsOneWidget);
      expect(find.text('Патент на изобретение (C1)'), findsOneWidget);
      expect(find.text('ООО Ромашка'), findsOneWidget);
      expect(find.text('Иванов И.И.'), findsOneWidget);
      expect(find.text('Петров П.П.'), findsOneWidget);
    });

    testWidgets('касание столбца показывает подсказку без ошибок', (tester) async {
      await openAnalytics(tester, items: makePage(total: 10).items, total: 10);
      await tester.pumpAndSettle();

      // держим палец на столбце: fl_chart рисует подсказку, пока касание активно
      final gesture = await tester.startGesture(tester.getCenter(find.byType(BarChart)));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('мало публикаций (≤5 в год) — график строится', (tester) async {
      await openAnalytics(tester, items: makePage(total: 3).items, total: 3);
      await tester.pumpAndSettle();
      expect(find.byType(BarChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('много лет: подписи оси X прорежены', (tester) async {
      final items = [
        for (var i = 0; i < 15; i++)
          PatentSummary(id: 'RU${i + 1}C1_${2005 + i}0101', ipc: 'G06F 1/00', patentees: 'ООО А', inventors: 'А'),
      ];
      await openAnalytics(tester, items: items, total: 15);
      await tester.pumpAndSettle();

      expect(find.byType(BarChart), findsOneWidget);
      for (final shown in ['2005', '2008', '2011', '2014', '2017']) {
        expect(find.text(shown), findsOneWidget, reason: shown);
      }
      expect(find.text('2006'), findsNothing);
      expect(find.text('2007'), findsNothing);
    });

    testWidgets('малые доли в легенде показаны с процентами', (tester) async {
      final items = [
        for (var i = 0; i < 19; i++) PatentSummary(id: 'RU${i + 1}C1_20190101', ipc: 'G06F 1/00'),
        const PatentSummary(id: 'RU99C1_20190101', ipc: 'A61K 1/00'),
      ];
      await openAnalytics(tester, items: items, total: 20);
      await tester.pumpAndSettle();

      expect(find.text('G — Физика'), findsOneWidget);
      expect(find.text('19 · 95%'), findsOneWidget);
      expect(find.text('A — Человеческие потребности'), findsOneWidget);
      expect(find.text('1 · 5%'), findsOneWidget);
      expect(find.byType(PieChart), findsOneWidget);
    });

    testWidgets('пустая выборка: карточки скрыты, плитки остаются', (tester) async {
      await openAnalytics(tester, items: const [], total: 0);
      await tester.pumpAndSettle();

      expect(find.text('Анализ текущей страницы: 0 из 0 патентов'), findsOneWidget);
      expect(find.text('Найдено'), findsOneWidget);
      expect(find.byType(BarChart), findsNothing);
      expect(find.byType(PieChart), findsNothing);
      for (final title in [
        'Публикации по годам', 'Тематика (разделы МПК)', 'Типы документов',
        'Топ правообладателей', 'Топ авторов',
      ]) {
        expect(find.text(title), findsNothing, reason: title);
      }
    });

    testWidgets('патенты без распознаваемых данных не создают пустых карточек', (tester) async {
      await openAnalytics(tester, items: const [PatentSummary(id: 'weird')], total: 1);
      await tester.pumpAndSettle();
      expect(find.text('Публикации по годам'), findsNothing);
      expect(find.text('Типы документов'), findsNothing);
      expect(find.text('Топ авторов'), findsNothing);
      expect(find.text('Анализ текущей страницы: 1 из 1 патентов'), findsOneWidget);
    });
  });

  group('расширенная выборка', () {
    testWidgets('сначала страница, затем расширенные данные', (tester) async {
      final gate = Completer<SearchPage>();
      patents.searchHandler = (q, p, s) => gate.future;
      await openAnalytics(tester, items: makePage(total: 25).items, total: 25);
      await tester.pump();

      expect(find.text('Показана текущая страница (10 из 25). Загружаем расширенную выборку…'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(patents.searchCalls.single.page, 0);
      expect(patents.searchCalls.single.pageSize, 100);
      expect(patents.searchCalls.single.query.text, 'x');

      gate.complete(makePage(total: 25, pageSize: 100));
      await tester.pumpAndSettle();

      expect(find.text('Анализ первых 25 из 25 найденных патентов (в порядке выбранной сортировки)'), findsOneWidget);
      expect(find.text('Показана текущая страница (10 из 25). Загружаем расширенную выборку…'), findsNothing);
    });

    testWidgets('не удалось загрузить — остаются данные страницы', (tester) async {
      patents.searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await openAnalytics(tester, items: makePage(total: 25).items, total: 25);
      await tester.pumpAndSettle();

      expect(find.text('Анализ текущей страницы: 10 из 25 патентов'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });
  });

  testWidgets('кнопка «назад» закрывает экран', (tester) async {
    useTallScreen(tester);
    await pumpPushed(
      tester,
      () => AnalyzePage(query: const SearchQuery(), pageItems: makePage(total: 10).items, totalFound: 10),
      deps: buildDeps(patents: patents),
    );
    await tester.pumpAndSettle();
    expect(find.text('Аналитика'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Аналитика'), findsNothing);
  });
}

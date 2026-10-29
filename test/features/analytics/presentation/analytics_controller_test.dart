import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/analytics/domain/usecases/compute_patent_stats.dart';
import 'package:rospatent/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository repo;
  const query = SearchQuery(text: 'x');

  AnalyticsController build({required int pageCount, required int total, int limit = 100}) {
    final page = makePage(total: total, pageSize: pageCount, count: pageCount);
    return AnalyticsController(
      computeStats: const ComputePatentStats(),
      searchPatents: SearchPatents(repo),
      query: query,
      pageItems: page.items,
      totalFound: total,
      sampleLimit: limit,
    );
  }

  setUp(() => repo = FakePatentRepository());

  test('сразу считает статистику по текущей странице', () {
    final c = build(pageCount: 10, total: 500);
    expect(c.stats.sampleSize, 10);
    expect(c.stats.totalFound, 500);
    expect(c.loading, isFalse);
    expect(c.extended, isFalse);
  });

  group('start', () {
    test('если страница уже содержит все результаты — запрос не нужен', () async {
      final c = build(pageCount: 5, total: 5);
      await c.start();
      expect(repo.searchCalls, isEmpty);
      expect(c.extended, isFalse);
      expect(c.loading, isFalse);
    });

    test('подгружает расширенную выборку и пересчитывает статистику', () async {
      repo.searchHandler = (q, page, size) async => makePage(total: 500, page: 0, pageSize: size);
      final c = build(pageCount: 10, total: 500, limit: 50);
      var n = 0;
      c.addListener(() => n++);

      final future = c.start();
      expect(c.loading, isTrue);
      await future;

      expect(repo.searchCalls.single.page, 0);
      expect(repo.searchCalls.single.pageSize, 50);
      expect(repo.searchCalls.single.query, same(query));
      expect(c.extended, isTrue);
      expect(c.loading, isFalse);
      expect(c.stats.sampleSize, 50);
      expect(c.stats.totalFound, 500);
      expect(n, 2);
    });

    test('лимит выборки по умолчанию — 100', () async {
      final c = build(pageCount: 10, total: 500);
      await c.start();
      expect(repo.searchCalls.single.pageSize, 100);
    });

    test('пустой ответ: остаёмся на данных страницы', () async {
      repo.searchHandler = (q, page, size) async =>
          const SearchPage(items: [], total: 0, page: 0, pageSize: 100);
      final c = build(pageCount: 10, total: 500);
      await c.start();
      expect(c.extended, isFalse);
      expect(c.stats.sampleSize, 10);
      expect(c.loading, isFalse);
    });

    test('ошибка запроса: остаёмся на данных страницы', () async {
      repo.searchHandler = (q, page, size) => Future.error(const NetworkFailure());
      final c = build(pageCount: 10, total: 500);
      await c.start();
      expect(c.extended, isFalse);
      expect(c.stats.sampleSize, 10);
      expect(c.loading, isFalse);
    });
  });

  test('после dispose завершение запроса безопасно', () async {
    final completer = Completer<SearchPage>();
    repo.searchHandler = (q, p, s) => completer.future;
    final c = build(pageCount: 10, total: 500);
    final future = c.start();
    c.dispose();
    completer.complete(makePage(total: 500, pageSize: 100));
    await future;
  });
}

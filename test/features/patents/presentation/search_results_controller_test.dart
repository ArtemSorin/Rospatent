import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';
import 'package:rospatent/features/patents/presentation/controllers/search_results_controller.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository repo;
  late SearchResultsController controller;
  const query = SearchQuery(text: 'робот');

  setUp(() {
    repo = FakePatentRepository(total: 25);
    controller = SearchResultsController(searchPatents: SearchPatents(repo), query: query);
  });

  test('начальное состояние', () {
    expect(controller.page, isNull);
    expect(controller.currentPage, 0);
    expect(controller.loading, isFalse);
    expect(controller.error, isNull);
    expect(controller.totalPages, 0);
    expect(controller.pageSize, 10);
  });

  test('успешная загрузка заполняет страницу и сбрасывает loading', () async {
    await controller.load(0);
    expect(controller.page, isNotNull);
    expect(controller.page!.items.length, 10);
    expect(controller.currentPage, 0);
    expect(controller.loading, isFalse);
    expect(controller.error, isNull);
    expect(controller.totalPages, 3);
    expect(repo.searchCalls.single.query, same(query));
  });

  test('загрузка другой страницы обновляет currentPage и offset', () async {
    await controller.load(0);
    await controller.load(2);
    expect(controller.currentPage, 2);
    expect(controller.page!.items.length, 5);
    expect(repo.searchCalls.last.page, 2);
  });

  test('слушатели получают уведомления о старте и завершении', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    final future = controller.load(0);
    expect(controller.loading, isTrue);
    await future;
    expect(notifications, 2);
  });

  test('пользовательский размер страницы передаётся в поиск', () async {
    final c = SearchResultsController(searchPatents: SearchPatents(repo), query: query, pageSize: 5);
    await c.load(1);
    expect(repo.searchCalls.single.pageSize, 5);
    expect(c.totalPages, 5);
  });

  group('ошибки', () {
    test('Failure: текст ошибки, страница не появляется', () async {
      repo.searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await controller.load(0);
      expect(controller.error, 'Нет соединения с сервером');
      expect(controller.page, isNull);
      expect(controller.loading, isFalse);
    });

    test('неизвестная ошибка: общее сообщение', () async {
      repo.searchHandler = (q, p, s) => Future.error(StateError('bug'));
      await controller.load(0);
      expect(controller.error, 'Не удалось загрузить результаты');
    });

    test('ошибка следующей страницы сохраняет предыдущую и её номер', () async {
      await controller.load(0);
      final previous = controller.page;
      repo.searchHandler = (q, p, s) => Future.error(const ServerFailure('Ошибка сервера (500)'));
      await controller.load(1);
      expect(controller.error, 'Ошибка сервера (500)');
      expect(controller.page, same(previous));
      expect(controller.currentPage, 0);
    });

    test('новая успешная загрузка сбрасывает ошибку', () async {
      repo.searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await controller.load(0);
      repo.searchHandler = null;
      await controller.load(0);
      expect(controller.error, isNull);
      expect(controller.page, isNotNull);
    });

    test('retry повторяет загрузку текущей страницы', () async {
      await controller.load(1);
      repo.searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await controller.load(2);
      repo.searchHandler = null;
      await controller.retry();
      expect(repo.searchCalls.last.page, 1);
      expect(controller.error, isNull);
    });
  });

  group('гонки запросов', () {
    test('устаревший ответ игнорируется', () async {
      final slow = Completer<SearchPage>();
      final fast = Completer<SearchPage>();
      repo.searchHandler = (q, page, s) => page == 0 ? slow.future : fast.future;

      final first = controller.load(0);
      final second = controller.load(1);

      fast.complete(makePage(page: 1));
      await second;
      slow.complete(makePage(page: 0));
      await first;

      expect(controller.currentPage, 1);
      expect(controller.page!.page, 1);
      expect(controller.loading, isFalse);
    });

    test('устаревшая ошибка тоже игнорируется', () async {
      final slow = Completer<SearchPage>();
      repo.searchHandler = (q, page, s) => page == 0 ? slow.future : Future.value(makePage(page: 1));

      final first = controller.load(0);
      await controller.load(1);
      slow.completeError(const NetworkFailure());
      await first;

      expect(controller.error, isNull);
      expect(controller.currentPage, 1);
    });

    test('устаревшая неизвестная ошибка игнорируется', () async {
      final slow = Completer<SearchPage>();
      repo.searchHandler = (q, page, s) => page == 0 ? slow.future : Future.value(makePage(page: 1));

      final first = controller.load(0);
      await controller.load(1);
      slow.completeError(StateError('late'));
      await first;

      expect(controller.error, isNull);
    });
  });

  test('после dispose завершение запроса не вызывает уведомлений и исключений', () async {
    final completer = Completer<SearchPage>();
    repo.searchHandler = (q, p, s) => completer.future;
    final future = controller.load(0);
    controller.dispose();
    completer.complete(makePage());
    await future; // не должно бросить
  });
}

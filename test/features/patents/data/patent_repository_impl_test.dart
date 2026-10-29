import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/patents/data/datasources/rospatent_remote_data_source.dart';
import 'package:rospatent/features/patents/data/repositories/patent_repository_impl.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../../../helpers/http_helpers.dart';
import '../../../helpers/test_data.dart';

/// Удалённый источник с подменяемыми ответами (в обход HTTP).
class _FakeRemote extends RospatentRemoteDataSource {
  _FakeRemote({this.searchResult, this.documentResult, this.error})
    : super(client: MockClient((r) async => http.Response('', 200)), apiKey: 'k');

  final Map<String, dynamic>? searchResult;
  final Map<String, dynamic>? documentResult;
  final Object? error;
  Map<String, dynamic>? lastBody;
  String? lastId;

  @override
  Future<Map<String, dynamic>> search(Map<String, dynamic> body) async {
    lastBody = body;
    if (error != null) throw error!;
    return searchResult ?? {};
  }

  @override
  Future<Map<String, dynamic>> getDocument(String id) async {
    lastId = id;
    if (error != null) throw error!;
    return documentResult ?? {};
  }
}

void main() {
  group('search', () {
    test('формирует SearchPage из ответа', () async {
      final remote = _FakeRemote(searchResult: searchJson(total: 42));
      final repo = PatentRepositoryImpl(remote);

      final page = await repo.search(const SearchQuery(text: 'x'), page: 2, pageSize: 5);

      expect(page.total, 42);
      expect(page.page, 2);
      expect(page.pageSize, 5);
      expect(page.items.length, 2);
      expect(page.items.first.id, 'RU1C1_20200101');
      expect(remote.lastBody!['offset'], 10);
      expect(remote.lastBody!['limit'], 5);
      expect(remote.lastBody!['qn'], 'x');
    });

    test('значения по умолчанию: страница 0, размер 10', () async {
      final remote = _FakeRemote(searchResult: searchJson());
      await PatentRepositoryImpl(remote).search(const SearchQuery());
      expect(remote.lastBody!['offset'], 0);
      expect(remote.lastBody!['limit'], 10);
    });

    test('hits отсутствует или не список -> пустая страница', () async {
      expect((await PatentRepositoryImpl(_FakeRemote(searchResult: {'total': 3})).search(const SearchQuery())).items, isEmpty);
      expect((await PatentRepositoryImpl(_FakeRemote(searchResult: {'hits': 'x'})).search(const SearchQuery())).items, isEmpty);
    });

    test('нечисловой или отсутствующий total -> 0', () async {
      expect((await PatentRepositoryImpl(_FakeRemote(searchResult: {'hits': [], 'total': 'abc'})).search(const SearchQuery())).total, 0);
      expect((await PatentRepositoryImpl(_FakeRemote(searchResult: {'hits': []})).search(const SearchQuery())).total, 0);
    });

    test('total приходит строкой — разбирается', () async {
      expect((await PatentRepositoryImpl(_FakeRemote(searchResult: {'hits': [], 'total': '17'})).search(const SearchQuery())).total, 17);
    });

    test('элементы hits, не являющиеся словарями, пропускаются', () async {
      final page = await PatentRepositoryImpl(_FakeRemote(searchResult: {
        'hits': ['мусор', 5, {'id': 'ok'}],
        'total': 1,
      })).search(const SearchQuery());
      expect(page.items.map((e) => e.id).toList(), ['ok']);
    });

    test('Failure источника пробрасывается как есть', () async {
      final repo = PatentRepositoryImpl(_FakeRemote(error: const NetworkFailure()));
      await expectLater(repo.search(const SearchQuery()), throwsA(isA<NetworkFailure>()));
    });

    test('неразбираемая находка -> ParsingFailure', () async {
      final repo = PatentRepositoryImpl(_FakeRemote(searchResult: {
        'hits': [{1: 2}], // ключи не строки
      }));
      await expectLater(repo.search(const SearchQuery()), throwsA(isA<ParsingFailure>()));
    });
  });

  group('getDetails', () {
    test('разбирает документ', () async {
      final remote = _FakeRemote(documentResult: docJson());
      final d = await PatentRepositoryImpl(remote).getDetails('RU2701234C1_20190925');
      expect(remote.lastId, 'RU2701234C1_20190925');
      expect(d.title, 'Способ');
      expect(d.inventors.length, 2);
    });

    test('подставляет запрошенный id, если в ответе его нет', () async {
      final d = await PatentRepositoryImpl(_FakeRemote(documentResult: {})).getDetails('my-id');
      expect(d.id, 'my-id');
    });

    test('Failure источника пробрасывается', () async {
      final repo = PatentRepositoryImpl(_FakeRemote(error: const ServerFailure('x', statusCode: 500)));
      await expectLater(repo.getDetails('x'), throwsA(isA<ServerFailure>()));
    });

    test('неразбираемый документ -> ParsingFailure', () async {
      final repo = PatentRepositoryImpl(_FakeRemote(documentResult: {
        'common': {1: 2}, // ключи не строки
      }));
      await expectLater(repo.getDetails('x'), throwsA(isA<ParsingFailure>()));
    });
  });

  group('вместе с настоящим HTTP-источником', () {
    test('полный путь search -> JSON -> SearchPage', () async {
      final remote = RospatentRemoteDataSource(
        client: MockClient((r) async => jsonResponse(searchJson(total: 7))),
        apiKey: 'k',
      );
      final page = await PatentRepositoryImpl(remote).search(const SearchQuery());
      expect(page.total, 7);
      expect(page.items.length, 2);
    });
  });
}

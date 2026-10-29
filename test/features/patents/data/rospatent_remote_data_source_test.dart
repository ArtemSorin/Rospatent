import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/patents/data/datasources/rospatent_remote_data_source.dart';

import '../../../helpers/http_helpers.dart';

void main() {
  RospatentRemoteDataSource build(
    Future<http.Response> Function(http.Request) handler, {
    String baseUrl = 'https://example.test/api/',
    Duration timeout = const Duration(seconds: 5),
  }) => RospatentRemoteDataSource(
    client: MockClient(handler),
    apiKey: 'Bearer secret',
    baseUrl: baseUrl,
    timeout: timeout,
  );

  group('search', () {
    test('отправляет POST на /search с ключом и JSON-телом', () async {
      late http.Request seen;
      final ds = build((r) async {
        seen = r;
        return jsonResponse({'total': 1, 'hits': []});
      });

      final result = await ds.search({'qn': 'робот', 'limit': 10});

      expect(seen.method, 'POST');
      expect(seen.url.toString(), 'https://example.test/api/search');
      expect(seen.headers['Authorization'], 'Bearer secret');
      expect(seen.headers['Content-Type'], 'application/json');
      expect(jsonDecode(seen.body), {'qn': 'робот', 'limit': 10});
      expect(result['total'], 1);
    });

    test('корректно декодирует кириллицу в ответе', () async {
      final ds = build((r) async => jsonResponse({'title': 'Способ обработки'}));
      expect((await ds.search({}))['title'], 'Способ обработки');
    });

    test('базовый URL по умолчанию — Роспатент', () async {
      late Uri url;
      final ds = RospatentRemoteDataSource(
        client: MockClient((r) async {
          url = r.url;
          return jsonResponse({});
        }),
        apiKey: 'k',
      );
      await ds.search({});
      expect(url.toString(), 'https://searchplatform.rospatent.gov.ru/patsearch/v0.2/search');
    });
  });

  group('getDocument', () {
    test('отправляет GET на docs/{id}', () async {
      late http.Request seen;
      final ds = build((r) async {
        seen = r;
        return jsonResponse({'id': 'RU1C1_20200101'});
      });

      final result = await ds.getDocument('RU1C1_20200101');

      expect(seen.method, 'GET');
      expect(seen.url.toString(), 'https://example.test/api/docs/RU1C1_20200101');
      expect(seen.headers['Authorization'], 'Bearer secret');
      expect(result['id'], 'RU1C1_20200101');
    });

    test('экранирует спецсимволы в id', () async {
      late Uri url;
      final ds = build((r) async {
        url = r.url;
        return jsonResponse({});
      });
      await ds.getDocument('a b/c');
      expect(url.toString(), 'https://example.test/api/docs/a%20b%2Fc');
    });
  });

  group('ошибки', () {
    test('статус не 200 -> ServerFailure с кодом', () async {
      final ds = build((r) async => http.Response('oops', 500));
      await expectLater(
        ds.search({}),
        throwsA(predicate((e) =>
            e is ServerFailure && e.statusCode == 500 && e.message == 'Ошибка сервера (500)')),
      );
    });

    test('401 тоже ServerFailure', () async {
      final ds = build((r) async => http.Response('', 401));
      await expectLater(ds.getDocument('x'),
          throwsA(predicate((e) => e is ServerFailure && e.statusCode == 401)));
    });

    test('SocketException -> NetworkFailure', () async {
      final ds = build((r) async => throw const SocketException('нет сети'));
      await expectLater(ds.search({}),
          throwsA(predicate((e) => e is NetworkFailure && e.message == 'Нет соединения с сервером')));
    });

    test('ClientException -> NetworkFailure', () async {
      final ds = build((r) async => throw http.ClientException('сбой'));
      await expectLater(ds.getDocument('x'), throwsA(isA<NetworkFailure>()));
    });

    test('таймаут -> NetworkFailure с отдельным сообщением', () async {
      final never = Completer<http.Response>();
      final ds = build((r) => never.future, timeout: const Duration(milliseconds: 20));
      await expectLater(
        ds.search({}),
        throwsA(predicate((e) =>
            e is NetworkFailure && e.message == 'Сервер не отвечает, попробуйте позже')),
      );
    });

    test('невалидный JSON -> ParsingFailure', () async {
      final ds = build((r) async => http.Response('{not json', 200));
      await expectLater(ds.search({}), throwsA(isA<ParsingFailure>()));
    });

    test('JSON, но не объект -> ParsingFailure', () async {
      final ds = build((r) async => jsonResponse([1, 2, 3]));
      await expectLater(ds.getDocument('x'), throwsA(isA<ParsingFailure>()));
    });
  });
}

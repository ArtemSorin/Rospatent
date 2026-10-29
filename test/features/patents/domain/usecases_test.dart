import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/usecases/get_patent_details.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_data.dart';

void main() {
  group('SearchPatents', () {
    test('передаёт запрос, страницу и размер в репозиторий', () async {
      final repo = FakePatentRepository();
      const query = SearchQuery(text: 'робот');

      final page = await SearchPatents(repo)(query, page: 2, pageSize: 5);

      expect(repo.searchCalls.length, 1);
      expect(repo.searchCalls.single.query, same(query));
      expect(repo.searchCalls.single.page, 2);
      expect(repo.searchCalls.single.pageSize, 5);
      expect(page.page, 2);
    });

    test('значения по умолчанию: страница 0, размер 10', () async {
      final repo = FakePatentRepository();
      await SearchPatents(repo)(const SearchQuery());
      expect(repo.searchCalls.single.page, 0);
      expect(repo.searchCalls.single.pageSize, 10);
    });

    test('ошибки репозитория пробрасываются', () async {
      final repo = FakePatentRepository()
        ..searchHandler = (q, p, s) => Future.error(const NetworkFailure());
      await expectLater(SearchPatents(repo)(const SearchQuery()), throwsA(isA<NetworkFailure>()));
    });
  });

  group('GetPatentDetails', () {
    test('возвращает документ без подсказки как есть', () async {
      final repo = FakePatentRepository();
      final d = await GetPatentDetails(repo)('RU1');
      expect(repo.detailsCalls, ['RU1']);
      expect(d.id, 'RU1');
      expect(d.title, 'Способ обработки данных');
    });

    test('дополняет пустые поля подсказкой из поиска', () async {
      final repo = FakePatentRepository()
        ..detailsHandler = (id) async => makeDetails(
          id: id, title: '', inventors: const [], patentees: const [],
          applicant: '', ipc: '', cpc: '',
        );
      final d = await GetPatentDetails(repo)(
        'RU1',
        hint: makeSummary(title: 'Из <em>поиска</em>', inventors: 'А, Б', patentees: 'ООО В'),
      );
      expect(d.title, 'Из поиска');
      expect(d.inventors, ['А', 'Б']);
      expect(d.patentees, ['ООО В']);
    });

    test('ошибки репозитория пробрасываются', () async {
      final repo = FakePatentRepository()
        ..detailsHandler = (id) => Future.error(const ServerFailure('x'));
      await expectLater(GetPatentDetails(repo)('x'), throwsA(isA<ServerFailure>()));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:rospatent/features/favorites/data/models/favorite_patent_model.dart';

import '../../../helpers/fake_database.dart';
import '../../../helpers/test_data.dart';

Map<String, Object?> row(String id, int addedAt) => FavoritePatentModel.toMap(
  makeFavorite(id: id, addedAt: DateTime.fromMillisecondsSinceEpoch(addedAt)),
);

void main() {
  late FakeDatabaseOpener opener;
  late FavoritesLocalDataSource ds;

  setUp(() {
    opener = FakeDatabaseOpener();
    ds = FavoritesLocalDataSource(pathProvider: () async => '/data/db', opener: opener.call);
  });

  group('открытие базы', () {
    test('открывается лениво, по пути из провайдера, версия 1', () async {
      expect(opener.openedPaths, isEmpty);
      await ds.getAll();
      expect(opener.openedPaths, ['/data/db/rospatent.db']);
      expect(opener.openedVersion, 1);
    });

    test('создаёт таблицу favorites и индекс по added_at', () async {
      await ds.getAll();
      final sql = opener.db.executed;
      expect(sql.length, 2);
      expect(sql[0], contains('CREATE TABLE favorites'));
      for (final column in [
        'id', 'title', 'description', 'application_number', 'document_number',
        'kind', 'guid', 'country', 'lang', 'ipc', 'cpc', 'inventor',
        'patentee', 'applicant', 'publication_date', 'filing_date', 'added_at',
      ]) {
        expect(sql[0], contains(column));
      }
      expect(sql[0], contains('PRIMARY KEY'));
      expect(sql[1], contains('CREATE INDEX idx_favorites_added_at'));
    });

    test('база открывается один раз даже при параллельных вызовах', () async {
      await Future.wait([ds.getAll(), ds.exists('a'), ds.getAll()]);
      expect(opener.openedPaths.length, 1);
    });
  });

  group('операции', () {
    test('upsert добавляет, повторный upsert заменяет строку', () async {
      await ds.upsert(row('A', 1));
      await ds.upsert({...row('A', 1), 'title': 'Новое название'});
      final all = await ds.getAll();
      expect(all.length, 1);
      expect(all.single['title'], 'Новое название');
    });

    test('getAll возвращает новые записи первыми', () async {
      await ds.upsert(row('old', 1));
      await ds.upsert(row('new', 3));
      await ds.upsert(row('mid', 2));
      expect((await ds.getAll()).map((r) => r['id']).toList(), ['new', 'mid', 'old']);
    });

    test('exists отличает добавленное от отсутствующего', () async {
      await ds.upsert(row('A', 1));
      expect(await ds.exists('A'), isTrue);
      expect(await ds.exists('B'), isFalse);
    });

    test('delete удаляет запись', () async {
      await ds.upsert(row('A', 1));
      await ds.delete('A');
      expect(await ds.exists('A'), isFalse);
      expect(await ds.getAll(), isEmpty);
    });

    test('delete несуществующей записи безопасен', () async {
      await ds.delete('нет');
      expect(await ds.getAll(), isEmpty);
    });
  });

  group('ошибки базы данных', () {
    setUp(() => opener.db.failWith = FakeDatabaseException());

    test('getAll -> StorageFailure', () async {
      await expectLater(ds.getAll(), throwsA(isA<StorageFailure>()));
    });
    test('upsert -> StorageFailure', () async {
      await expectLater(ds.upsert(row('A', 1)), throwsA(isA<StorageFailure>()));
    });
    test('delete -> StorageFailure', () async {
      await expectLater(ds.delete('A'), throwsA(isA<StorageFailure>()));
    });
    test('exists -> StorageFailure', () async {
      await expectLater(ds.exists('A'), throwsA(isA<StorageFailure>()));
    });
  });

  test('посторонние (не sqflite) ошибки не маскируются', () async {
    opener.db.failWith = StateError('bug');
    await expectLater(ds.getAll(), throwsA(isA<StateError>()));
  });
}

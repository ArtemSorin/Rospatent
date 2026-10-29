import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/favorites/domain/usecases/add_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/get_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/is_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/migrate_legacy_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/restore_favorite.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_data.dart';

void main() {
  late InMemoryFavoritesRepository repo;
  setUp(() => repo = InMemoryFavoritesRepository());

  group('AddFavorite', () {
    test('сохраняет избранное, собранное из PatentDetails', () async {
      await AddFavorite(repo)(makeDetails(id: 'A', title: 'Название'));
      expect(repo.store.keys.toList(), ['A']);
      expect(repo.store['A']!.title, 'Название');
    });

    test('повторное добавление не создаёт дубликат', () async {
      await AddFavorite(repo)(makeDetails(id: 'A'));
      await AddFavorite(repo)(makeDetails(id: 'A'));
      expect(repo.store.length, 1);
    });

    test('ошибка репозитория пробрасывается', () async {
      repo.addError = const StorageFailure();
      await expectLater(AddFavorite(repo)(makeDetails()), throwsA(isA<StorageFailure>()));
    });
  });

  group('RestoreFavorite', () {
    test('возвращает удалённый патент как есть', () async {
      final f = makeFavorite(id: 'R');
      await RestoreFavorite(repo)(f);
      expect(repo.store['R'], same(f));
    });
  });

  group('RemoveFavorite', () {
    test('удаляет по id', () async {
      repo.store['A'] = makeFavorite(id: 'A');
      await RemoveFavorite(repo)('A');
      expect(repo.store, isEmpty);
    });

    test('удаление несуществующего не падает', () async {
      await RemoveFavorite(repo)('нет такого');
      expect(repo.store, isEmpty);
    });
  });

  group('IsFavorite', () {
    test('true для добавленного и false для остальных', () async {
      repo.store['A'] = makeFavorite(id: 'A');
      expect(await IsFavorite(repo)('A'), isTrue);
      expect(await IsFavorite(repo)('B'), isFalse);
    });
  });

  group('GetFavorites', () {
    test('новые добавления идут первыми', () async {
      repo.store['old'] = makeFavorite(id: 'old', addedAt: DateTime(2020));
      repo.store['new'] = makeFavorite(id: 'new', addedAt: DateTime(2024));
      repo.store['mid'] = makeFavorite(id: 'mid', addedAt: DateTime(2022));
      final list = await GetFavorites(repo)();
      expect(list.map((e) => e.id).toList(), ['new', 'mid', 'old']);
    });

    test('пустое избранное', () async {
      expect(await GetFavorites(repo)(), isEmpty);
    });
  });

  group('MigrateLegacyFavorites', () {
    late FakePatentRepository patents;
    setUp(() => patents = FakePatentRepository());

    MigrateLegacyFavorites build(FakeLegacyStore legacy) =>
        MigrateLegacyFavorites(legacy, repo, patents);

    test('если старых данных нет — ничего не делает', () async {
      final legacy = FakeLegacyStore(null);
      await build(legacy)();
      expect(patents.detailsCalls, isEmpty);
      expect(legacy.writes, isEmpty);
    });

    test('подтягивает данные каждого id и очищает старое хранилище', () async {
      final legacy = FakeLegacyStore(['A', 'B']);
      await build(legacy)();
      expect(patents.detailsCalls, ['A', 'B']);
      expect(repo.store.keys.toSet(), {'A', 'B'});
      expect(repo.store['A']!.title, 'Способ обработки данных');
      expect(legacy.writes, [<String>[]]);
      expect(legacy.ids, isNull);
    });

    test('повторяющиеся id обрабатываются один раз', () async {
      await build(FakeLegacyStore(['A', 'A', 'A']))();
      expect(patents.detailsCalls, ['A']);
    });

    test('уже сохранённые в SQLite патенты пропускаются', () async {
      repo.store['A'] = makeFavorite(id: 'A', title: 'Уже есть');
      await build(FakeLegacyStore(['A']))();
      expect(patents.detailsCalls, isEmpty);
      expect(repo.store['A']!.title, 'Уже есть');
    });

    test('не загрузившиеся id остаются в старом хранилище', () async {
      patents.detailsHandler = (id) async {
        if (id == 'BAD') throw const NetworkFailure();
        return makeDetails(id: id);
      };
      final legacy = FakeLegacyStore(['OK', 'BAD']);
      await build(legacy)();
      expect(repo.store.keys.toList(), ['OK']);
      expect(legacy.writes, [['BAD']]);
      expect(legacy.ids, ['BAD']);
    });

    test('ошибка записи в SQLite тоже оставляет id на следующий запуск', () async {
      repo.addError = const StorageFailure();
      final legacy = FakeLegacyStore(['A']);
      await build(legacy)();
      expect(legacy.ids, ['A']);
    });

    test('пустой список в старом хранилище очищает ключ', () async {
      final legacy = FakeLegacyStore(<String>[]);
      await build(legacy)();
      expect(legacy.writes, [<String>[]]);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:rospatent/features/favorites/data/repositories/favorites_repository_impl.dart';

import '../../../helpers/fake_database.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FavoritesRepositoryImpl repo;

  setUp(() {
    final opener = FakeDatabaseOpener();
    repo = FavoritesRepositoryImpl(
      FavoritesLocalDataSource(pathProvider: () async => '/db', opener: opener.call),
    );
  });

  test('пустое избранное', () async {
    expect(await repo.getAll(), isEmpty);
  });

  test('add -> getAll возвращает сохранённый патент целиком', () async {
    final f = makeFavorite(addedAt: DateTime.fromMillisecondsSinceEpoch(9000));
    await repo.add(f);

    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.single.id, f.id);
    expect(all.single.title, f.title);
    expect(all.single.applicationNumber, f.applicationNumber);
    expect(all.single.inventors, f.inventors);
    expect(all.single.publicationDate, f.publicationDate);
  });

  test('isFavorite отражает добавление и удаление', () async {
    expect(await repo.isFavorite('A'), isFalse);
    await repo.add(makeFavorite(id: 'A'));
    expect(await repo.isFavorite('A'), isTrue);
    await repo.remove('A');
    expect(await repo.isFavorite('A'), isFalse);
  });

  test('порядок: сначала самые новые', () async {
    await repo.add(makeFavorite(id: 'a', addedAt: DateTime.fromMillisecondsSinceEpoch(1)));
    await repo.add(makeFavorite(id: 'b', addedAt: DateTime.fromMillisecondsSinceEpoch(2)));
    expect((await repo.getAll()).map((e) => e.id).toList(), ['b', 'a']);
  });

  test('повторное add заменяет запись', () async {
    await repo.add(makeFavorite(id: 'a', title: 'v1'));
    await repo.add(makeFavorite(id: 'a', title: 'v2'));
    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.single.title, 'v2');
  });
}

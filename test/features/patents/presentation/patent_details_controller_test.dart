import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/favorites/domain/usecases/add_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/is_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/usecases/get_patent_details.dart';
import 'package:rospatent/features/patents/presentation/controllers/patent_details_controller.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository patents;
  late InMemoryFavoritesRepository favorites;

  PatentDetailsController build({String id = 'RU1', hint}) => PatentDetailsController(
    getPatentDetails: GetPatentDetails(patents),
    isFavorite: IsFavorite(favorites),
    addFavorite: AddFavorite(favorites),
    removeFavorite: RemoveFavorite(favorites),
    patentId: id,
    hint: hint,
  );

  setUp(() {
    patents = FakePatentRepository();
    favorites = InMemoryFavoritesRepository();
  });

  test('начальное состояние — идёт загрузка', () {
    final c = build();
    expect(c.loading, isTrue);
    expect(c.details, isNull);
    expect(c.favorite, isFalse);
    expect(c.error, isNull);
    expect(c.patentId, 'RU1');
  });

  group('load', () {
    test('успех: данные загружены, флаг избранного выставлен', () async {
      favorites.store['RU1'] = makeFavorite(id: 'RU1');
      final c = build();
      await c.load();
      expect(c.details!.id, 'RU1');
      expect(c.favorite, isTrue);
      expect(c.loading, isFalse);
      expect(c.error, isNull);
    });

    test('уведомляет слушателей минимум о старте и завершении', () async {
      final c = build();
      var n = 0;
      c.addListener(() => n++);
      await c.load();
      expect(n, 2);
    });

    test('подсказка из поиска дополняет пустые поля', () async {
      patents.detailsHandler = (id) async => makeDetails(id: id, inventors: const [], patentees: const []);
      final c = build(hint: makeSummary(inventors: 'А, Б', patentees: 'ООО В'));
      await c.load();
      expect(c.details!.inventors, ['А', 'Б']);
      expect(c.details!.patentees, ['ООО В']);
    });

    test('Failure при загрузке: текст ошибки, details остаётся пустым', () async {
      patents.detailsHandler = (id) => Future.error(const NetworkFailure());
      final c = build();
      await c.load();
      expect(c.error, 'Нет соединения с сервером');
      expect(c.details, isNull);
      expect(c.loading, isFalse);
    });

    test('неизвестная ошибка: общее сообщение', () async {
      patents.detailsHandler = (id) => Future.error(StateError('bug'));
      final c = build();
      await c.load();
      expect(c.error, 'Не удалось загрузить патент');
    });

    test('ошибка проверки избранного не мешает загрузке', () async {
      favorites.isFavoriteError = const StorageFailure();
      final c = build();
      await c.load();
      expect(c.favorite, isFalse);
      expect(c.details, isNotNull);
      expect(c.error, isNull);
    });

    test('повторная загрузка сбрасывает ошибку', () async {
      patents.detailsHandler = (id) => Future.error(const NetworkFailure());
      final c = build();
      await c.load();
      patents.detailsHandler = null;
      await c.load();
      expect(c.error, isNull);
      expect(c.details, isNotNull);
    });
  });

  group('toggleFavorite', () {
    test('без загруженных данных ничего не делает', () async {
      final c = build();
      await c.toggleFavorite();
      expect(favorites.store, isEmpty);
      expect(c.favorite, isFalse);
    });

    test('добавляет в избранное, затем убирает', () async {
      final c = build();
      await c.load();

      await c.toggleFavorite();
      expect(c.favorite, isTrue);
      expect(favorites.store.containsKey('RU1'), isTrue);
      expect(favorites.store['RU1']!.title, 'Способ обработки данных');

      await c.toggleFavorite();
      expect(c.favorite, isFalse);
      expect(favorites.store, isEmpty);
    });

    test('уведомляет слушателей об изменении звезды', () async {
      final c = build();
      await c.load();
      var n = 0;
      c.addListener(() => n++);
      await c.toggleFavorite();
      expect(n, 1);
    });

    test('ошибка хранилища оставляет прежнее состояние', () async {
      final c = build();
      await c.load();
      favorites.addError = const StorageFailure();
      await c.toggleFavorite();
      expect(c.favorite, isFalse);

      favorites.addError = null;
      await c.toggleFavorite();
      favorites.removeError = const StorageFailure();
      await c.toggleFavorite();
      expect(c.favorite, isTrue);
    });
  });

  test('после dispose завершение загрузки не вызывает исключений', () async {
    final completer = Completer<PatentDetails>();
    patents.detailsHandler = (id) => completer.future;
    final c = build();
    final future = c.load();
    await Future<void>.delayed(Duration.zero);
    c.dispose();
    completer.complete(makeDetails());
    await future;
  });
}

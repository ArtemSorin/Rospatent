import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/favorites/domain/usecases/get_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/restore_favorite.dart';
import 'package:rospatent/features/favorites/presentation/controllers/favorites_controller.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_data.dart';

void main() {
  late InMemoryFavoritesRepository repo;
  late FavoritesController controller;

  setUp(() {
    repo = InMemoryFavoritesRepository([
      makeFavorite(id: 'A', addedAt: DateTime(2024, 1, 1)),
      makeFavorite(id: 'B', addedAt: DateTime(2024, 2, 1)),
    ]);
    controller = FavoritesController(
      getFavorites: GetFavorites(repo),
      removeFavorite: RemoveFavorite(repo),
      restoreFavorite: RestoreFavorite(repo),
    );
  });

  test('начальное состояние', () {
    expect(controller.items, isEmpty);
    expect(controller.loading, isTrue);
    expect(controller.error, isNull);
  });

  group('load', () {
    test('загружает список, новые первыми', () async {
      await controller.load();
      expect(controller.items.map((e) => e.id).toList(), ['B', 'A']);
      expect(controller.loading, isFalse);
      expect(controller.error, isNull);
    });

    test('ошибка: сообщение и loading=false', () async {
      repo.getAllError = const StorageFailure();
      await controller.load();
      expect(controller.error, 'Не удалось загрузить избранное');
      expect(controller.loading, isFalse);
    });

    test('успешная повторная загрузка сбрасывает ошибку', () async {
      repo.getAllError = const StorageFailure();
      await controller.load();
      repo.getAllError = null;
      await controller.load();
      expect(controller.error, isNull);
      expect(controller.items.length, 2);
    });

    test('уведомляет слушателей', () async {
      var n = 0;
      controller.addListener(() => n++);
      await controller.load();
      expect(n, 1);
    });
  });

  group('remove', () {
    test('сразу убирает элемент из списка и из хранилища', () async {
      await controller.load();
      final future = controller.remove(controller.items.first);
      expect(controller.items.map((e) => e.id).toList(), ['A']); // оптимистично
      await future;
      expect(repo.store.keys.toList(), ['A']);
    });

    test('при ошибке хранилища список перезагружается', () async {
      await controller.load();
      repo.removeError = const StorageFailure();
      await controller.remove(controller.items.first);
      expect(controller.items.length, 2); // вернулось из хранилища
    });
  });

  group('restore', () {
    test('возвращает патент и перезагружает список', () async {
      await controller.load();
      final removed = controller.items.first;
      await controller.remove(removed);
      await controller.restore(removed);
      expect(controller.items.map((e) => e.id).toList(), ['B', 'A']);
    });

    test('при ошибке всё равно перезагружает список и пробрасывает ошибку', () async {
      await controller.load();
      repo.addError = const StorageFailure();
      await expectLater(controller.restore(makeFavorite(id: 'Z')), throwsA(isA<StorageFailure>()));
      expect(controller.items.length, 2);
    });
  });

  test('после dispose уведомления не отправляются и ошибок нет', () async {
    final c = FavoritesController(
      getFavorites: GetFavorites(repo),
      removeFavorite: RemoveFavorite(repo),
      restoreFavorite: RestoreFavorite(repo),
    );
    final future = c.load();
    c.dispose();
    await future;
  });
}

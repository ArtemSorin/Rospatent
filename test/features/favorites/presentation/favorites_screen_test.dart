import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/patent_details_screen.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository patents;
  late InMemoryFavoritesRepository favorites;

  Future<void> openFavorites(WidgetTester tester) async {
    useTallScreen(tester);
    await pumpScoped(
      tester,
      const FavoritePage(),
      deps: buildDeps(patents: patents, favorites: favorites),
    );
  }

  setUp(() {
    patents = FakePatentRepository();
    favorites = InMemoryFavoritesRepository();
  });

  group('состояния экрана', () {
    testWidgets('пока список грузится — индикатор', (tester) async {
      favorites.getAllGate = Completer<void>();
      await openFavorites(tester);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      favorites.getAllGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('пустое избранное — подсказка', (tester) async {
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(find.text('У вас пока нет избранных патентов'), findsOneWidget);
      expect(find.text('Добавляйте патенты в избранное, чтобы быстро находить их позже'), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });

    testWidgets('ошибка загрузки — сообщение без подсказки', (tester) async {
      favorites.getAllError = const StorageFailure();
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(find.text('Не удалось загрузить избранное'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Добавляйте патенты в избранное, чтобы быстро находить их позже'), findsNothing);
    });

    testWidgets('шапка: заголовок и кнопки', (tester) async {
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(find.text('Избранное'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.account_circle_outlined));
      await tester.tap(find.byIcon(Icons.notifications_none));
      expect(tester.takeException(), isNull);
    });
  });

  group('карточка избранного', () {
    testWidgets('показывает название, описание, идентификаторы и данные', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A');
      await openFavorites(tester);
      await tester.pumpAndSettle();

      expect(find.text('Способ обработки данных'), findsOneWidget);
      expect(find.text('Краткое описание патента'), findsOneWidget);
      expect(find.text('Патент на изобретение'), findsOneWidget);
      expect(findRich('Заявка №: 2018111222'), findsOneWidget);
      expect(findRich('Публикация: RU 2701234 C1'), findsOneWidget);
      expect(findRich('МПК: G06F 17/30'), findsOneWidget);
      expect(findRich('Авторы: Иванов И.И., Петров П.П.'), findsOneWidget);
      expect(findRich('Правообладатель: ООО Ромашка'), findsOneWidget);
      expect(findRich('Даты: подана 28.03.2018 · опубликована 25.09.2019'), findsOneWidget);
      expect(findRich('ID: A'), findsOneWidget);
    });

    testWidgets('пустые поля не выводятся', (tester) async {
      favorites.store['X'] = FavoritePatent(id: 'X', title: '', addedAt: DateTime(2024));
      await openFavorites(tester);
      await tester.pumpAndSettle();

      expect(find.text('Без названия'), findsOneWidget);
      expect(findRich('Заявка №'), findsNothing);
      expect(findRich('Публикация'), findsNothing);
      expect(findRich('МПК'), findsNothing);
      expect(findRich('Авторы'), findsNothing);
      expect(findRich('Правообладатель'), findsNothing);
      expect(findRich('Даты'), findsNothing);
      expect(findRich('ID: X'), findsOneWidget); // идентификатор есть всегда
      expect(find.text('Патент на изобретение'), findsNothing); // чипа вида нет
    });

    testWidgets('без правообладателя показывается заявитель', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', patentees: '', applicant: 'ИП Кузнецов');
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(findRich('Правообладатель: ИП Кузнецов'), findsOneWidget);
    });

    testWidgets('в «Даты» попадает только то, что известно', (tester) async {
      favorites.store['A'] = FavoritePatent(
        id: 'A', title: 'T', filingDate: DateTime(2018, 3, 28), addedAt: DateTime(2024),
      );
      favorites.store['B'] = FavoritePatent(
        id: 'B', title: 'T', publicationDate: DateTime(2019, 9, 25), addedAt: DateTime(2023),
      );
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(findRich('Даты: подана 28.03.2018'), findsOneWidget);
      expect(findRich('Даты: опубликована 25.09.2019'), findsOneWidget);
    });

    testWidgets('описание скрыто, если пустое; публикация без номера документа', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', description: '', documentNumber: null, country: 'RU', kind: 'U1');
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(find.text('Краткое описание патента'), findsNothing);
      expect(findRich('Публикация: RU U1'), findsOneWidget);
      expect(find.text('Полезная модель'), findsOneWidget);
    });

    testWidgets('новые записи идут выше старых', (tester) async {
      favorites.store['old'] = makeFavorite(id: 'old', title: 'Старый', addedAt: DateTime(2020));
      favorites.store['new'] = makeFavorite(id: 'new', title: 'Новый', addedAt: DateTime(2024));
      await openFavorites(tester);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Новый')).dy, lessThan(tester.getTopLeft(find.text('Старый')).dy));
    });
  });

  group('удаление', () {
    testWidgets('звезда удаляет патент, «Отменить» возвращает', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', title: 'Первый');
      await openFavorites(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();
      expect(find.text('Первый'), findsNothing);
      expect(find.text('Удалено из избранного'), findsOneWidget);
      expect(favorites.store, isEmpty);
      expect(find.text('У вас пока нет избранных патентов'), findsOneWidget);

      await tester.tap(find.text('Отменить'));
      await tester.pumpAndSettle();
      expect(find.text('Первый'), findsOneWidget);
      expect(favorites.store.keys.toList(), ['A']);
    });

    testWidgets('свайп влево удаляет патент', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', title: 'Первый');
      favorites.store['B'] = makeFavorite(id: 'B', title: 'Второй', addedAt: DateTime(2025));
      await openFavorites(tester);
      await tester.pumpAndSettle();

      await tester.drag(find.byType(Dismissible).first, const Offset(-700, 0));
      await tester.pumpAndSettle();

      expect(find.text('Второй'), findsNothing);
      expect(find.text('Первый'), findsOneWidget);
      expect(find.text('Удалено из избранного'), findsOneWidget);
      expect(favorites.store.keys.toList(), ['A']);
    });

    testWidgets('свайп вправо не удаляет', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', title: 'Первый');
      await openFavorites(tester);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Dismissible), const Offset(700, 0));
      await tester.pumpAndSettle();
      expect(find.text('Первый'), findsOneWidget);
      expect(favorites.store.length, 1);
    });
  });

  testWidgets('экран закрыт во время удаления — снекбар не показывается и ошибок нет', (tester) async {
    favorites.store['A'] = makeFavorite(id: 'A');
    favorites.removeGate = Completer<void>();
    useTallScreen(tester);
    await pumpPushed(tester, () => const FavoritePage(), deps: buildDeps(patents: patents, favorites: favorites));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.star)); // удаление зависло на removeGate
    await tester.pump();

    tester.state<NavigatorState>(find.byType(Navigator)).pop(); // закрываем экран
    await tester.pumpAndSettle();
    expect(find.byType(FavoritePage), findsNothing);

    favorites.removeGate!.complete();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Удалено из избранного'), findsNothing);
    expect(favorites.store, isEmpty);
  });

  group('открытие патента', () {
    testWidgets('нажатие на карточку открывает экран патента с данными из избранного', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', title: 'Первый');
      await openFavorites(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Первый'));
      await tester.pumpAndSettle();

      expect(find.byType(PatentDetailsPage), findsOneWidget);
      expect(patents.detailsCalls, ['A']);
    });

    testWidgets('убрали патент из избранного на его экране — список обновляется после возврата', (tester) async {
      favorites.store['A'] = makeFavorite(id: 'A', title: 'Первый');
      await openFavorites(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Первый'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.star)); // патент уже в избранном → убираем
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.byType(PatentDetailsPage), findsNothing);
      expect(find.text('У вас пока нет избранных патентов'), findsOneWidget);
    });
  });
}

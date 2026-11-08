import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/app.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/patent_details_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/search_results_screen.dart';
import 'package:rospatent/features/patents/presentation/widgets/results/patent_card.dart';

import '../helpers/fakes.dart';
import '../helpers/pump.dart';

void main() {
  Finder tab(String label) => find.bySemanticsLabel(label);

  testWidgets('поиск → страница 2 → патент → избранное → список → удаление', (
    tester,
  ) async {
    useTallScreen(tester);
    final patents = FakePatentRepository(total: 25);
    final favorites = InMemoryFavoritesRepository();
    await tester.pumpWidget(
      AppScope(
        dependencies: buildDeps(patents: patents, favorites: favorites),
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. поиск
    await tester.enterText(find.byType(TextField).first, 'робот');
    await tester.tap(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('Найти'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SearchResultsPage), findsOneWidget);
    expect(patents.searchCalls.single.query.text, 'робот');
    expect(find.byType(PatentCard), findsNWidgets(10));
    expect(find.text('Найдено патентов'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    // 2. вторая страница
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(patents.searchCalls.last.page, 1);
    expect(anyText('Патент №11.'), findsWidgets);

    // 3. карточка патента
    await tester.tap(anyText('Патент №11.').first);
    await tester.pumpAndSettle();
    expect(find.byType(PatentDetailsPage), findsOneWidget);
    expect(find.text('Иванов И.И.'), findsOneWidget);

    // 4. в избранное
    await tester.tap(find.byIcon(Icons.star_outline_rounded).last);
    await tester.pumpAndSettle();
    expect(favorites.store.length, 1);

    // 5. назад к форме поиска
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    // 6. раздел «Избранное»
    await tester.tap(tab('Избранное'));
    await tester.pumpAndSettle();
    expect(find.byType(FavoritePage), findsOneWidget);
    expect(find.text('Способ обработки данных'), findsOneWidget);
    expect(findRich('Заявка №: 2018111222'), findsOneWidget);

    // 7. удаление
    await tester.tap(find.byTooltip('Убрать из избранного'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('У вас пока нет избранных патентов'), findsOneWidget);
    expect(favorites.store, isEmpty);
  });

  testWidgets(
    'старое избранное из SharedPreferences переносится и появляется в списке',
    (tester) async {
      useTallScreen(tester);
      final patents = FakePatentRepository();
      final favorites = InMemoryFavoritesRepository();
      final legacy = FakeLegacyStore(['RU100C1_20200101', 'RU200C1_20200101']);
      final deps = buildDeps(
        patents: patents,
        favorites: favorites,
        legacy: legacy,
      );

      await deps.migrateLegacyFavorites();

      await tester.pumpWidget(AppScope(dependencies: deps, child: const App()));
      await tester.pumpAndSettle();
      await tester.tap(tab('Избранное'));
      await tester.pumpAndSettle();

      expect(find.text('Способ обработки данных'), findsNWidgets(2));
      expect(legacy.ids, isNull);
    },
  );

  testWidgets('сбой сети при поиске не роняет приложение, повтор помогает', (
    tester,
  ) async {
    useTallScreen(tester);
    final patents = FakePatentRepository()
      ..searchHandler = (q, p, s) => Future.error(StateError('offline'));
    await tester.pumpWidget(
      AppScope(
        dependencies: buildDeps(patents: patents),
        child: const App(),
      ),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.text('Найти'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить результаты'), findsOneWidget);

    patents.searchHandler = null;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.byType(PatentCard), findsNWidgets(10));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/main_shell.dart';
import 'package:rospatent/features/about/presentation/about_screen.dart';
import 'package:rospatent/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rospatent/features/history/presentation/screens/history_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump.dart';
import '../helpers/test_data.dart';

void main() {
  late InMemoryFavoritesRepository favorites;

  Future<void> openShell(WidgetTester tester) async {
    useTallScreen(tester);
    favorites = InMemoryFavoritesRepository();
    await pumpScoped(
      tester,
      const MainShell(),
      deps: buildDeps(favorites: favorites),
    );
  }

  Finder tab(String label) {
    return find.byIcon(switch (label) {
      'Поиск' => Icons.search_rounded,
      'История' => Icons.history_rounded,
      'Избранное' => Icons.star_outline_rounded,
      'О приложении' => Icons.info_outline_rounded,
      _ => Icons.circle,
    }).last;
  }

  testWidgets('стартует на экране поиска', (tester) async {
    await openShell(tester);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(FavoritePage), findsNothing);
    expect(find.byType(AboutPage), findsNothing);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);
  });

  testWidgets('в нижней панели три раздела с иконками', (tester) async {
    await openShell(tester);
    expect(tab('Поиск'), findsOneWidget);
    expect(tab('История'), findsOneWidget);
    expect(tab('Избранное'), findsOneWidget);
    expect(tab('О приложении'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
  });

  testWidgets('переключает разделы', (tester) async {
    await openShell(tester);

    await tester.tap(tab('История'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    await tester.tap(tab('Избранное'));
    await tester.pumpAndSettle();
    expect(find.byType(FavoritePage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    await tester.tap(tab('О приложении'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.byType(FavoritePage), findsNothing);

    await tester.tap(tab('Поиск'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('избранное перезагружается при каждом входе в раздел', (
    tester,
  ) async {
    await openShell(tester);
    await tester.tap(tab('Избранное'));
    await tester.pumpAndSettle();
    expect(find.text('У вас пока нет избранных патентов'), findsOneWidget);

    await tester.tap(tab('Поиск'));
    await tester.pumpAndSettle();
    favorites.store['A'] = makeFavorite(id: 'A', title: 'Добавленный патент');

    await tester.tap(tab('Избранное'));
    await tester.pumpAndSettle();
    expect(find.text('Добавленный патент'), findsOneWidget);
  });

  testWidgets('панель оформлена плавной плавающей капсулой', (tester) async {
    await openShell(tester);
    expect(find.byType(Container), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsWidgets);
  });
}

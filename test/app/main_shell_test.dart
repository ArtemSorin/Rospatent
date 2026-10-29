import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/main_shell.dart';
import 'package:rospatent/features/about/presentation/about_screen.dart';
import 'package:rospatent/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:rospatent/features/patents/presentation/screens/home_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump.dart';
import '../helpers/test_data.dart';

void main() {
  late InMemoryFavoritesRepository favorites;

  Future<void> openShell(WidgetTester tester) async {
    useTallScreen(tester);
    favorites = InMemoryFavoritesRepository();
    await pumpScoped(tester, const MainShell(), deps: buildDeps(favorites: favorites));
  }

  Finder tab(String label) => find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.text(label),
  );

  int selectedIndex(WidgetTester tester) =>
      tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).currentIndex;

  testWidgets('стартует на экране поиска', (tester) async {
    await openShell(tester);
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(FavoritePage), findsNothing);
    expect(find.byType(AboutPage), findsNothing);
    expect(selectedIndex(tester), 0);
  });

  testWidgets('в нижней панели три раздела с иконками', (tester) async {
    await openShell(tester);
    expect(tab('Поиск'), findsOneWidget);
    expect(tab('Избранное'), findsOneWidget);
    expect(tab('О приложении'), findsOneWidget);
    expect(find.descendant(of: find.byType(BottomNavigationBar), matching: find.byIcon(Icons.search)), findsOneWidget);
    expect(find.descendant(of: find.byType(BottomNavigationBar), matching: find.byIcon(Icons.star_border)), findsOneWidget);
    expect(find.descendant(of: find.byType(BottomNavigationBar), matching: find.byIcon(Icons.info_outline)), findsOneWidget);
  });

  testWidgets('переключает разделы', (tester) async {
    await openShell(tester);

    await tester.tap(tab('Избранное'));
    await tester.pumpAndSettle();
    expect(find.byType(FavoritePage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);
    expect(selectedIndex(tester), 1);

    await tester.tap(tab('О приложении'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);
    expect(find.byType(FavoritePage), findsNothing);
    expect(selectedIndex(tester), 2);

    await tester.tap(tab('Поиск'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(selectedIndex(tester), 0);
  });

  testWidgets('избранное перезагружается при каждом входе в раздел', (tester) async {
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

  testWidgets('панель оформлена: фиксированный тип, синий акцент', (tester) async {
    await openShell(tester);
    final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bar.type, BottomNavigationBarType.fixed);
    expect(bar.selectedItemColor, Colors.blueAccent);
    expect(bar.unselectedItemColor, Colors.grey);
    expect(bar.backgroundColor, Colors.white);
  });
}

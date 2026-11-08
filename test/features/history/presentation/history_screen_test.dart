import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/history/presentation/screens/history_screen.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump.dart';

SearchHistoryEntry historyEntry({
  String text = 'робот',
  SortOrder sort = SortOrder.relevance,
  List<String> authors = const [],
  List<String> patentees = const [],
  DateTime? from,
  DateTime? to,
}) => SearchHistoryEntry(
  query: SearchQuery(
    text: text,
    sort: sort,
    authors: authors,
    patentees: patentees,
    publishedFrom: from,
    publishedTo: to,
  ),
  searchedAt: DateTime.now().subtract(const Duration(hours: 1)),
);

void main() {
  testWidgets('пустое состояние и заголовок истории', (tester) async {
    useTallScreen(tester);
    await pumpScoped(tester, const HistoryPage());
    await tester.pumpAndSettle();

    expect(find.text('История'), findsOneWidget);
    expect(find.text('История пуста'), findsOneWidget);
    expect(find.textContaining('повторить в одно касание'), findsOneWidget);
  });

  testWidgets('ошибка загрузки предлагает повторить запрос', (tester) async {
    final history = InMemorySearchHistoryRepository();
    history.getAllError = StateError('storage');
    useTallScreen(tester);
    await pumpScoped(tester, const HistoryPage(), deps: buildDeps(history: history));
    await tester.pumpAndSettle();

    expect(find.text('Не удалось загрузить'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('карточка показывает параметры запроса и дату', (tester) async {
    final entry = historyEntry(
      text: 'нейросети',
      sort: SortOrder.publicationDesc,
      authors: const ['Иванов И.И.'],
      patentees: const ['ООО Ромашка'],
      from: DateTime(2023, 2, 3),
      to: DateTime(2024, 4, 5),
    );
    final history = InMemorySearchHistoryRepository([entry]);
    useTallScreen(tester);
    await pumpScoped(tester, const HistoryPage(), deps: buildDeps(history: history));
    await tester.pumpAndSettle();

    expect(find.text('нейросети'), findsOneWidget);
    expect(find.text('Автор: Иванов И.И.'), findsOneWidget);
    expect(find.text('ООО Ромашка'), findsOneWidget);
    expect(find.textContaining('с 03.02.2023'), findsOneWidget);
    expect(find.textContaining('по 05.04.2024'), findsOneWidget);
    expect(find.textContaining('Сегодня'), findsOneWidget);
  });

  testWidgets('удаление записи доступно кнопкой', (tester) async {
    final entry = historyEntry();
    final history = InMemorySearchHistoryRepository([entry]);
    useTallScreen(tester);
    await pumpScoped(tester, const HistoryPage(), deps: buildDeps(history: history));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Удалить из истории'));
    await tester.pumpAndSettle();
    expect(history.store, isEmpty);
    expect(find.text('Запрос удалён из истории'), findsOneWidget);
  });
}

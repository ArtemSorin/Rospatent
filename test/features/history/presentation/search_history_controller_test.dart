import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/history/domain/usecases/add_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/clear_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/get_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/remove_search_history.dart';
import 'package:rospatent/features/history/presentation/controllers/search_history_controller.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../../../helpers/fakes.dart';

SearchHistoryEntry makeHistory({
  String text = 'робот',
  DateTime? at,
}) => SearchHistoryEntry(
  query: SearchQuery(text: text),
  searchedAt: at ?? DateTime(2024, 1, 2, 15, 30),
);

void main() {
  SearchHistoryController controllerFor(InMemorySearchHistoryRepository repository) {
    return SearchHistoryController(
      getHistory: GetSearchHistory(repository),
      addHistory: AddSearchHistory(repository),
      removeHistory: RemoveSearchHistory(repository),
      clearHistory: ClearSearchHistory(repository),
    );
  }

  test('загружает историю и преобразует ошибки', () async {
    final repository = InMemorySearchHistoryRepository([makeHistory()]);
    final controller = controllerFor(repository);
    await controller.load();
    expect(controller.items, hasLength(1));
    expect(controller.loading, isFalse);
    expect(controller.error, isNull);

    repository.getAllError = StateError('storage');
    await controller.load();
    expect(controller.items, hasLength(1));
    expect(controller.error, 'Не удалось загрузить историю');
    controller.dispose();
  });

  test('удаляет, восстанавливает, очищает и повторно добавляет запись', () async {
    final entry = makeHistory();
    final repository = InMemorySearchHistoryRepository([entry]);
    final controller = controllerFor(repository);

    await controller.remove(entry);
    expect(controller.items, isEmpty);
    await controller.restore(entry);
    expect(controller.items, [entry]);
    await controller.clear();
    expect(controller.items, isEmpty);

    await controller.bump(makeHistory(text: 'новый запрос'));
    await controller.load();
    expect(controller.items.single.query.text, 'новый запрос');
    controller.dispose();
  });
}

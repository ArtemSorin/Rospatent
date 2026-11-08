import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../entities/search_history_entry.dart';
import '../repositories/search_history_repository.dart';

class AddSearchHistory {
  final SearchHistoryRepository _repository;
  const AddSearchHistory(this._repository);

  /// Пустые запросы (без текста и фильтров) в историю не попадают.
  Future<void> call(SearchQuery query, {DateTime? at}) async {
    final entry = SearchHistoryEntry(
      query: query,
      searchedAt: at ?? DateTime.now(),
    );
    if (!entry.hasCriteria) return;
    await _repository.add(entry);
  }

  /// Возврат удалённой записи (отмена удаления).
  Future<void> restore(SearchHistoryEntry entry) => _repository.add(entry);
}

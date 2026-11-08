import '../entities/search_history_entry.dart';

abstract class SearchHistoryRepository {
  /// Сначала новые.
  Future<List<SearchHistoryEntry>> getAll();

  /// Добавляет запрос наверх списка; такой же запрос, если был, заменяется.
  Future<void> add(SearchHistoryEntry entry);

  Future<void> remove(SearchHistoryEntry entry);

  Future<void> clear();
}

import '../entities/search_history_entry.dart';
import '../repositories/search_history_repository.dart';

class RemoveSearchHistory {
  final SearchHistoryRepository _repository;
  const RemoveSearchHistory(this._repository);

  Future<void> call(SearchHistoryEntry entry) => _repository.remove(entry);
}

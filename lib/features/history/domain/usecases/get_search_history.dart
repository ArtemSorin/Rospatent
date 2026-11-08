import '../entities/search_history_entry.dart';
import '../repositories/search_history_repository.dart';

class GetSearchHistory {
  final SearchHistoryRepository _repository;
  const GetSearchHistory(this._repository);

  Future<List<SearchHistoryEntry>> call() => _repository.getAll();
}

import '../repositories/search_history_repository.dart';

class ClearSearchHistory {
  final SearchHistoryRepository _repository;
  const ClearSearchHistory(this._repository);

  Future<void> call() => _repository.clear();
}

import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/history/domain/repositories/search_history_repository.dart';

import '../datasources/search_history_local_data_source.dart';
import '../models/search_history_entry_model.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  /// Больше записей не храним — старые вытесняются.
  static const maxEntries = 50;

  final SearchHistoryLocalDataSource _local;
  SearchHistoryRepositoryImpl(this._local);

  @override
  Future<List<SearchHistoryEntry>> getAll() async {
    final rows = await _local.read();
    return rows
        .map(SearchHistoryEntryModel.decode)
        .whereType<SearchHistoryEntry>()
        .toList();
  }

  @override
  Future<void> add(SearchHistoryEntry entry) async {
    final all = await getAll();
    final next = [entry, ...all.where((e) => e.key != entry.key)];
    await _save(next.take(maxEntries).toList());
  }

  @override
  Future<void> remove(SearchHistoryEntry entry) async {
    final all = await getAll();
    await _save(all.where((e) => e.key != entry.key).toList());
  }

  @override
  Future<void> clear() => _local.write(const []);

  Future<void> _save(List<SearchHistoryEntry> entries) =>
      _local.write(entries.map(SearchHistoryEntryModel.encode).toList());
}

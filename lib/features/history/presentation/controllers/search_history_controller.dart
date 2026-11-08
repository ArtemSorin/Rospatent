import 'package:flutter/foundation.dart';
import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/history/domain/usecases/add_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/clear_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/get_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/remove_search_history.dart';

class SearchHistoryController extends ChangeNotifier {
  SearchHistoryController({
    required this._getHistory,
    required this._addHistory,
    required this._removeHistory,
    required this._clearHistory,
  });

  final GetSearchHistory _getHistory;
  final AddSearchHistory _addHistory;
  final RemoveSearchHistory _removeHistory;
  final ClearSearchHistory _clearHistory;

  List<SearchHistoryEntry> items = [];
  bool loading = true;
  String? error;

  bool _disposed = false;

  Future<void> load() async {
    try {
      items = await _getHistory();
      error = null;
    } catch (_) {
      error = 'Не удалось загрузить историю';
    }
    loading = false;
    _notify();
  }

  /// Запрос выполнен повторно — поднимаем его наверх списка.
  Future<void> bump(SearchHistoryEntry entry) async {
    try {
      await _addHistory(entry.query);
    } catch (_) {}
  }

  Future<void> remove(SearchHistoryEntry entry) async {
    items = items.where((e) => e.key != entry.key).toList();
    _notify();
    try {
      await _removeHistory(entry);
    } catch (_) {
      await load();
    }
  }

  Future<void> restore(SearchHistoryEntry entry) async {
    try {
      await _addHistory.restore(entry);
    } finally {
      await load();
    }
  }

  Future<void> clear() async {
    items = [];
    _notify();
    try {
      await _clearHistory();
    } catch (_) {
      await load();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

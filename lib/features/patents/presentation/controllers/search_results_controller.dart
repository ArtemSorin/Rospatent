import 'package:flutter/foundation.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';

/// Состояние экрана результатов поиска: текущая страница, загрузка, ошибка.
class SearchResultsController extends ChangeNotifier {
  SearchResultsController({
    required this._searchPatents,
    required this.query,
    this.pageSize = 10,
  });

  final SearchPatents _searchPatents;
  final SearchQuery query;
  final int pageSize;

  /// Последняя успешно загруженная страница.
  SearchPage? page;
  int currentPage = 0;
  bool loading = false;
  String? error;

  int _requestId = 0;
  bool _disposed = false;

  int get totalPages => page?.totalPages ?? 0;

  /// Загружает страницу [index] (с нуля). Устаревшие ответы игнорируются.
  Future<void> load(int index) async {
    final id = ++_requestId;
    loading = true;
    error = null;
    _notify();
    try {
      final result = await _searchPatents(query, page: index, pageSize: pageSize);
      if (id != _requestId) return;
      page = result;
      currentPage = index;
    } on Failure catch (e) {
      if (id != _requestId) return;
      error = e.message;
    } catch (_) {
      if (id != _requestId) return;
      error = 'Не удалось загрузить результаты';
    }
    loading = false;
    _notify();
  }

  Future<void> retry() => load(currentPage);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

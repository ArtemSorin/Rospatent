import 'dart:async';

import 'package:rospatent/app/injection.dart';
import 'package:rospatent/features/analytics/domain/usecases/compute_patent_stats.dart';
import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:rospatent/features/favorites/domain/repositories/legacy_favorites_store.dart';
import 'package:rospatent/features/favorites/domain/usecases/add_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/get_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/is_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/migrate_legacy_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/restore_favorite.dart';
import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/history/domain/repositories/search_history_repository.dart';
import 'package:rospatent/features/history/domain/usecases/add_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/clear_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/get_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/remove_search_history.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/repositories/patent_repository.dart';
import 'package:rospatent/features/patents/domain/usecases/get_patent_details.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';

import 'test_data.dart';

class SearchCall {
  final SearchQuery query;
  final int page;
  final int pageSize;
  const SearchCall(this.query, this.page, this.pageSize);
}

/// Репозиторий патентов с настраиваемым поведением.
class FakePatentRepository implements PatentRepository {
  final List<SearchCall> searchCalls = [];
  final List<String> detailsCalls = [];

  /// Всего результатов в выдаче по умолчанию.
  int total;

  Future<SearchPage> Function(SearchQuery query, int page, int pageSize)?
  searchHandler;
  Future<PatentDetails> Function(String id)? detailsHandler;

  FakePatentRepository({this.total = 25});

  @override
  Future<SearchPage> search(
    SearchQuery query, {
    int page = 0,
    int pageSize = 10,
  }) {
    searchCalls.add(SearchCall(query, page, pageSize));
    final handler = searchHandler;
    if (handler != null) return handler(query, page, pageSize);
    return Future.value(makePage(total: total, page: page, pageSize: pageSize));
  }

  @override
  Future<PatentDetails> getDetails(String id) {
    detailsCalls.add(id);
    final handler = detailsHandler;
    if (handler != null) return handler(id);
    return Future.value(makeDetails(id: id));
  }
}

/// Избранное в памяти, ведёт себя как БД (новые сверху).
class InMemoryFavoritesRepository implements FavoritesRepository {
  final Map<String, FavoritePatent> store = {};
  Object? getAllError;
  Object? addError;
  Object? removeError;
  Object? isFavoriteError;

  /// Если задан — getAll ждёт его завершения (чтобы проверять состояние загрузки).
  Completer<void>? getAllGate;

  /// Если задан — remove ждёт его завершения.
  Completer<void>? removeGate;

  InMemoryFavoritesRepository([Iterable<FavoritePatent> initial = const []]) {
    for (final f in initial) {
      store[f.id] = f;
    }
  }

  @override
  Future<List<FavoritePatent>> getAll() async {
    if (getAllGate != null) await getAllGate!.future;
    if (getAllError != null) throw getAllError!;
    final list = store.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return list;
  }

  @override
  Future<void> add(FavoritePatent patent) async {
    if (addError != null) throw addError!;
    store[patent.id] = patent;
  }

  @override
  Future<void> remove(String id) async {
    if (removeGate != null) await removeGate!.future;
    if (removeError != null) throw removeError!;
    store.remove(id);
  }

  @override
  Future<bool> isFavorite(String id) async {
    if (isFavoriteError != null) throw isFavoriteError!;
    return store.containsKey(id);
  }
}

class FakeLegacyStore implements LegacyFavoritesStore {
  List<String>? ids;
  final List<List<String>> writes = [];

  FakeLegacyStore([this.ids]);

  @override
  Future<List<String>?> readIds() async => ids;

  @override
  Future<void> writeIds(List<String> value) async {
    writes.add(List.of(value));
    ids = value.isEmpty ? null : List.of(value);
  }
}

class InMemorySearchHistoryRepository implements SearchHistoryRepository {
  final List<SearchHistoryEntry> store;
  Object? getAllError;
  Object? addError;
  Object? removeError;
  Object? clearError;

  InMemorySearchHistoryRepository([
    Iterable<SearchHistoryEntry> initial = const [],
  ]) : store = List.of(initial);

  @override
  Future<List<SearchHistoryEntry>> getAll() async {
    if (getAllError != null) throw getAllError!;
    return List.of(store);
  }

  @override
  Future<void> add(SearchHistoryEntry entry) async {
    if (addError != null) throw addError!;
    store.removeWhere((item) => item.key == entry.key);
    store.insert(0, entry);
  }

  @override
  Future<void> remove(SearchHistoryEntry entry) async {
    if (removeError != null) throw removeError!;
    store.removeWhere((item) => item.key == entry.key);
  }

  @override
  Future<void> clear() async {
    if (clearError != null) throw clearError!;
    store.clear();
  }
}

/// Собирает AppDependencies из реальных use case-ов поверх фейковых репозиториев.
AppDependencies buildDeps({
  PatentRepository? patents,
  FavoritesRepository? favorites,
  LegacyFavoritesStore? legacy,
  SearchHistoryRepository? history,
}) {
  final patentRepo = patents ?? FakePatentRepository();
  final favRepo = favorites ?? InMemoryFavoritesRepository();
  final historyRepo = history ?? InMemorySearchHistoryRepository();
  return AppDependencies(
    searchPatents: SearchPatents(patentRepo),
    getPatentDetails: GetPatentDetails(patentRepo),
    getFavorites: GetFavorites(favRepo),
    addFavorite: AddFavorite(favRepo),
    removeFavorite: RemoveFavorite(favRepo),
    restoreFavorite: RestoreFavorite(favRepo),
    isFavorite: IsFavorite(favRepo),
    migrateLegacyFavorites: MigrateLegacyFavorites(
      legacy ?? FakeLegacyStore(),
      favRepo,
      patentRepo,
    ),
    getSearchHistory: GetSearchHistory(historyRepo),
    addSearchHistory: AddSearchHistory(historyRepo),
    removeSearchHistory: RemoveSearchHistory(historyRepo),
    clearSearchHistory: ClearSearchHistory(historyRepo),
    computePatentStats: const ComputePatentStats(),
  );
}

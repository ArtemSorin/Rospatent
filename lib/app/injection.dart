import 'package:http/http.dart' as http;
import 'package:rospatent/auth/secrets.dart' as secrets;
import 'package:rospatent/features/analytics/domain/usecases/compute_patent_stats.dart';
import 'package:rospatent/features/favorites/data/datasources/favorites_local_data_source.dart';
import 'package:rospatent/features/favorites/data/datasources/legacy_favorites_data_source.dart';
import 'package:rospatent/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:rospatent/features/favorites/domain/usecases/add_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/get_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/is_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/migrate_legacy_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/restore_favorite.dart';
import 'package:rospatent/features/history/data/datasources/search_history_local_data_source.dart';
import 'package:rospatent/features/history/data/repositories/search_history_repository_impl.dart';
import 'package:rospatent/features/history/domain/usecases/add_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/clear_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/get_search_history.dart';
import 'package:rospatent/features/history/domain/usecases/remove_search_history.dart';
import 'package:rospatent/features/patents/data/datasources/rospatent_remote_data_source.dart';
import 'package:rospatent/features/patents/data/repositories/patent_repository_impl.dart';
import 'package:rospatent/features/patents/domain/usecases/get_patent_details.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';

/// Корень композиции: единственное место, где слои связываются между собой.
/// Экраны получают только use case-ы, о data-слое они ничего не знают.
class AppDependencies {
  final SearchPatents searchPatents;
  final GetPatentDetails getPatentDetails;

  final GetFavorites getFavorites;
  final AddFavorite addFavorite;
  final RemoveFavorite removeFavorite;
  final RestoreFavorite restoreFavorite;
  final IsFavorite isFavorite;
  final MigrateLegacyFavorites migrateLegacyFavorites;

  final GetSearchHistory getSearchHistory;
  final AddSearchHistory addSearchHistory;
  final RemoveSearchHistory removeSearchHistory;
  final ClearSearchHistory clearSearchHistory;

  final ComputePatentStats computePatentStats;

  const AppDependencies({
    required this.searchPatents,
    required this.getPatentDetails,
    required this.getFavorites,
    required this.addFavorite,
    required this.removeFavorite,
    required this.restoreFavorite,
    required this.isFavorite,
    required this.migrateLegacyFavorites,
    required this.getSearchHistory,
    required this.addSearchHistory,
    required this.removeSearchHistory,
    required this.clearSearchHistory,
    required this.computePatentStats,
  });

  factory AppDependencies.create() {
    // data
    final remote = RospatentRemoteDataSource(
      client: http.Client(),
      apiKey: secrets.apiKey,
    );
    final patentRepository = PatentRepositoryImpl(remote);
    final favoritesRepository = FavoritesRepositoryImpl(
      FavoritesLocalDataSource(),
    );
    final legacyStore = LegacyFavoritesDataSource();
    final historyRepository = SearchHistoryRepositoryImpl(
      SearchHistoryLocalDataSource(),
    );

    // domain
    return AppDependencies(
      searchPatents: SearchPatents(patentRepository),
      getPatentDetails: GetPatentDetails(patentRepository),
      getFavorites: GetFavorites(favoritesRepository),
      addFavorite: AddFavorite(favoritesRepository),
      removeFavorite: RemoveFavorite(favoritesRepository),
      restoreFavorite: RestoreFavorite(favoritesRepository),
      isFavorite: IsFavorite(favoritesRepository),
      migrateLegacyFavorites: MigrateLegacyFavorites(
        legacyStore,
        favoritesRepository,
        patentRepository,
      ),
      getSearchHistory: GetSearchHistory(historyRepository),
      addSearchHistory: AddSearchHistory(historyRepository),
      removeSearchHistory: RemoveSearchHistory(historyRepository),
      clearSearchHistory: ClearSearchHistory(historyRepository),
      computePatentStats: const ComputePatentStats(),
    );
  }
}

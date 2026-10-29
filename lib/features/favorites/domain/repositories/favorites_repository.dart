import '../entities/favorite_patent.dart';

abstract class FavoritesRepository {
  /// Новые добавления сверху.
  Future<List<FavoritePatent>> getAll();
  Future<void> add(FavoritePatent patent);
  Future<void> remove(String id);
  Future<bool> isFavorite(String id);
}

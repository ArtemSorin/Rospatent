import '../entities/favorite_patent.dart';
import '../repositories/favorites_repository.dart';

/// Возвращает в избранное ранее удалённый патент («Отменить»).
class RestoreFavorite {
  final FavoritesRepository _repository;
  const RestoreFavorite(this._repository);

  Future<void> call(FavoritePatent patent) => _repository.add(patent);
}

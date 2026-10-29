import '../entities/favorite_patent.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository _repository;
  const GetFavorites(this._repository);

  Future<List<FavoritePatent>> call() => _repository.getAll();
}

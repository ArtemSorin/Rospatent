import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  final FavoritesRepository _repository;
  const RemoveFavorite(this._repository);

  Future<void> call(String id) => _repository.remove(id);
}

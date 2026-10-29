import 'package:rospatent/features/patents/domain/entities/patent_details.dart';

import '../entities/favorite_patent.dart';
import '../repositories/favorites_repository.dart';

class AddFavorite {
  final FavoritesRepository _repository;
  const AddFavorite(this._repository);

  Future<void> call(PatentDetails details) =>
      _repository.add(FavoritePatent.fromDetails(details));
}

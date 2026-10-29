import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/favorites/domain/repositories/favorites_repository.dart';

import '../datasources/favorites_local_data_source.dart';
import '../models/favorite_patent_model.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource _local;
  const FavoritesRepositoryImpl(this._local);

  @override
  Future<List<FavoritePatent>> getAll() async =>
      (await _local.getAll()).map(FavoritePatentModel.fromMap).toList();

  @override
  Future<void> add(FavoritePatent patent) =>
      _local.upsert(FavoritePatentModel.toMap(patent));

  @override
  Future<void> remove(String id) => _local.delete(id);

  @override
  Future<bool> isFavorite(String id) => _local.exists(id);
}

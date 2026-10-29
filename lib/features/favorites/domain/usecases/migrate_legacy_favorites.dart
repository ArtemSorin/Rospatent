import 'package:rospatent/features/patents/domain/repositories/patent_repository.dart';

import '../entities/favorite_patent.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/legacy_favorites_store.dart';

/// Переносит старые избранные (только id) в SQLite: подтягивает данные
/// патента из API. Не загрузившиеся id остаются в старом хранилище
/// до следующего запуска.
class MigrateLegacyFavorites {
  final LegacyFavoritesStore _legacy;
  final FavoritesRepository _favorites;
  final PatentRepository _patents;

  const MigrateLegacyFavorites(this._legacy, this._favorites, this._patents);

  Future<void> call() async {
    final ids = await _legacy.readIds();
    if (ids == null) return;

    final remaining = <String>[];
    for (final id in ids.toSet()) {
      try {
        if (await _favorites.isFavorite(id)) continue;
        final details = await _patents.getDetails(id);
        await _favorites.add(FavoritePatent.fromDetails(details));
      } catch (_) {
        remaining.add(id);
      }
    }
    await _legacy.writeIds(remaining);
  }
}

import 'package:rospatent/features/favorites/domain/repositories/legacy_favorites_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Читает старое избранное из SharedPreferences (ключ «favorites»).
class LegacyFavoritesDataSource implements LegacyFavoritesStore {
  static const _key = 'favorites';

  @override
  Future<List<String>?> readIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key);
  }

  @override
  Future<void> writeIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    if (ids.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setStringList(_key, ids);
    }
  }
}

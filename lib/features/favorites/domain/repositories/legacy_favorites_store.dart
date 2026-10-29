/// Старое хранилище избранного (список id в SharedPreferences).
abstract class LegacyFavoritesStore {
  /// null — старых данных нет.
  Future<List<String>?> readIds();

  /// Сохраняет оставшиеся id; пустой список удаляет ключ целиком.
  Future<void> writeIds(List<String> ids);
}

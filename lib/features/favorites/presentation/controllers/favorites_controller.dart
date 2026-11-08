import 'package:flutter/foundation.dart';
import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/favorites/domain/usecases/get_favorites.dart';
import 'package:rospatent/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:rospatent/features/favorites/domain/usecases/restore_favorite.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController({
    required this._getFavorites,
    required this._removeFavorite,
    required this._restoreFavorite,
  });

  final GetFavorites _getFavorites;
  final RemoveFavorite _removeFavorite;
  final RestoreFavorite _restoreFavorite;

  List<FavoritePatent> items = [];
  bool loading = true;
  String? error;

  bool _disposed = false;

  Future<void> load() async {
    try {
      items = await _getFavorites();
      error = null;
    } catch (_) {
      error = 'Не удалось загрузить избранное';
    }
    loading = false;
    _notify();
  }

  Future<void> remove(FavoritePatent patent) async {
    items = items.where((e) => e.id != patent.id).toList();
    _notify();
    try {
      await _removeFavorite(patent.id);
    } catch (_) {
      await load();
    }
  }

  Future<void> restore(FavoritePatent patent) async {
    try {
      await _restoreFavorite(patent);
    } finally {
      await load();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Preferences prefs = Preferences();

  List<String> _favoriteIds = [];

  void addFavorite(String id) async {
    _favoriteIds.add(id);
    (await SharedPreferences.getInstance())
        .setStringList("favorites", _favoriteIds);
  }

  void removeFavorite(String id) async {
    _favoriteIds.remove(id);
    (await SharedPreferences.getInstance())
        .setStringList("favorites", _favoriteIds);
  }

  Future<List<String>> getFavorites() async {
    _favoriteIds =
        (await SharedPreferences.getInstance()).getStringList("favorites") ??
            [];
    return _favoriteIds;
  }

  Future<bool> isFavorites(String id) async {
    return (await getFavorites()).contains(id);
  }

  Preferences() {
    getFavorites();
  }
}

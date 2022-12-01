import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static Preferences prefs = Preferences();

  List<String> favoriteIds = [];

  void addFavorite(String id) async {
    favoriteIds.add(id);
    (await SharedPreferences.getInstance())
        .setStringList("favorites", favoriteIds);
  }

  void removeFavorite(String id) async {
    favoriteIds.remove(id);
    (await SharedPreferences.getInstance())
        .setStringList("favorites", favoriteIds);
  }

  Future<List<String>> getFavorites() async {
    favoriteIds =
        (await SharedPreferences.getInstance()).getStringList("favorites") ??
            [];
    return favoriteIds;
  }

  Future<bool> isFavorites(String id) async {
    return (await getFavorites()).contains(id);
  }

  Preferences() {
    getFavorites();
  }
}

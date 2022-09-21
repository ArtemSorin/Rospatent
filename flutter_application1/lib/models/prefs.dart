import 'package:shared_preferences/shared_preferences.dart';

Preferences prefs = Preferences();

class Preferences {
  SharedPreferences? prefs;

  List<String> _favoriteIds = [];

  void addFavorite(String id) {
    _favoriteIds.add(id);
    prefs!.setStringList("favorites", _favoriteIds);
  }

  void removeFavorite(String id) {
    _favoriteIds.remove(id);
    prefs!.setStringList("favorites", _favoriteIds);
  }

  List<String> getFavorites() {
    _favoriteIds = prefs!.getStringList("favorites") ?? [];
    return _favoriteIds;
  }

  Preferences() {
    _createPrefs();
    getFavorites();
  }

  void _createPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
}

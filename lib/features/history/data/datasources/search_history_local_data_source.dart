import 'package:shared_preferences/shared_preferences.dart';

/// Хранит историю как список JSON-строк в SharedPreferences.
class SearchHistoryLocalDataSource {
  static const _key = 'search_history_v1';

  Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  Future<void> write(List<String> rows) async {
    final prefs = await SharedPreferences.getInstance();
    if (rows.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setStringList(_key, rows);
    }
  }
}

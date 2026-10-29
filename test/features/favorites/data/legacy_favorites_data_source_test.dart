import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/favorites/data/datasources/legacy_favorites_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegacyFavoritesDataSource', () {
    test('readIds возвращает сохранённые id', () async {
      SharedPreferences.setMockInitialValues({'favorites': ['A', 'B']});
      expect(await LegacyFavoritesDataSource().readIds(), ['A', 'B']);
    });

    test('readIds возвращает null, если ключа нет', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await LegacyFavoritesDataSource().readIds(), isNull);
    });

    test('writeIds записывает оставшиеся id', () async {
      SharedPreferences.setMockInitialValues({'favorites': ['A', 'B']});
      final ds = LegacyFavoritesDataSource();
      await ds.writeIds(['B']);
      expect(await ds.readIds(), ['B']);
    });

    test('writeIds с пустым списком удаляет ключ целиком', () async {
      SharedPreferences.setMockInitialValues({'favorites': ['A']});
      final ds = LegacyFavoritesDataSource();
      await ds.writeIds([]);
      expect(await ds.readIds(), isNull);
    });
  });
}

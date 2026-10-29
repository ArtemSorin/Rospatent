import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/injection.dart';

void main() {
  group('AppDependencies.create', () {
    test('собирает все use case-ы', () {
      final deps = AppDependencies.create();
      expect(deps.searchPatents, isNotNull);
      expect(deps.getPatentDetails, isNotNull);
      expect(deps.getFavorites, isNotNull);
      expect(deps.addFavorite, isNotNull);
      expect(deps.removeFavorite, isNotNull);
      expect(deps.restoreFavorite, isNotNull);
      expect(deps.isFavorite, isNotNull);
      expect(deps.migrateLegacyFavorites, isNotNull);
      expect(deps.computePatentStats, isNotNull);
    });

    test('каждый вызов создаёт независимый набор зависимостей', () {
      expect(identical(AppDependencies.create(), AppDependencies.create()), isFalse);
    });
  });
}

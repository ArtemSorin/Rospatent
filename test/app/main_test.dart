import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/app.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/app/main_shell.dart';
import 'package:rospatent/main.dart' as entry;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('main() запускает приложение с зависимостями в AppScope', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    entry.main();
    await tester.pump();

    expect(find.byType(AppScope), findsOneWidget);
    expect(find.byType(App), findsOneWidget);
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Поиск по тексту патентов'), findsOneWidget);
  });
}

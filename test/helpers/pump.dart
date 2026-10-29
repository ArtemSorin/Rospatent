import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/app/injection.dart';

import 'fakes.dart';

/// Задаёт размер экрана в логических пикселях (devicePixelRatio = 1).
void useScreen(WidgetTester tester, {double width = 800, double height = 600}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Высокий экран: ленивые списки строят все элементы сразу.
void useTallScreen(WidgetTester tester, {double width = 800}) =>
    useScreen(tester, width: width, height: 6000);

/// Показывает [home] внутри AppScope + MaterialApp.
Future<void> pumpScoped(
  WidgetTester tester,
  Widget home, {
  AppDependencies? deps,
}) {
  return tester.pumpWidget(
    AppScope(
      dependencies: deps ?? buildDeps(),
      child: MaterialApp(home: home),
    ),
  );
}

/// Открывает страницу поверх стартового экрана, чтобы можно было проверить
/// возврат назад. После вызова нужен pump/pumpAndSettle.
Future<void> pumpPushed(
  WidgetTester tester,
  Widget Function() page, {
  AppDependencies? deps,
}) async {
  await pumpScoped(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    deps: deps,
  );
  await tester.tap(find.text('open'));
}

/// Ищет RichText (Text.rich) по подстроке итогового текста.
Finder findRich(String contains) => find.byWidgetPredicate(
  (w) => w is RichText && w.text.toPlainText().contains(contains),
);

/// Ищет текст и среди обычных Text, и среди RichText (подсветка в карточках
/// выдачи может строиться на RichText). Для проверки наличия используйте
/// findsWidgets: одно и то же слово может найтись и в Text, и в его RichText.
Finder anyText(String contains) => find.textContaining(contains, findRichText: true);

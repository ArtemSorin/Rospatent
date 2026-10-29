import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/app/injection.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('of возвращает зависимости из ближайшего AppScope', (tester) async {
    final deps = buildDeps();
    AppDependencies? found;
    await tester.pumpWidget(AppScope(
      dependencies: deps,
      child: Builder(builder: (context) {
        found = AppScope.of(context);
        return const SizedBox();
      }),
    ));
    expect(found, same(deps));
  });

  testWidgets('of доступен и из initState дочернего виджета', (tester) async {
    final deps = buildDeps();
    await tester.pumpWidget(AppScope(dependencies: deps, child: _InitStateReader(deps)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('без AppScope в дереве срабатывает assert', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        AppScope.of(context);
        return const SizedBox();
      }),
    ));
    expect(tester.takeException(), isA<AssertionError>());
  });

  test('updateShouldNotify: true для других зависимостей, false для тех же', () {
    final a = buildDeps();
    final b = buildDeps();
    const child = SizedBox();
    final scopeA = AppScope(dependencies: a, child: child);
    // ignore: invalid_use_of_protected_member
    expect(scopeA.updateShouldNotify(AppScope(dependencies: b, child: child)), isTrue);
    // ignore: invalid_use_of_protected_member
    expect(scopeA.updateShouldNotify(AppScope(dependencies: a, child: child)), isFalse);
  });
}

class _InitStateReader extends StatefulWidget {
  final AppDependencies expected;
  const _InitStateReader(this.expected);

  @override
  State<_InitStateReader> createState() => _InitStateReaderState();
}

class _InitStateReaderState extends State<_InitStateReader> {
  @override
  void initState() {
    super.initState();
    expect(AppScope.of(context), same(widget.expected));
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

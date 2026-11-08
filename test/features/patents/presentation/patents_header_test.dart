import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/presentation/widgets/results/patents_header.dart';

Future<void> pumpHeader(
  WidgetTester tester, {
  required int total,
  required int current,
  required int pages,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PatentsHeader(
          totalFound: total,
          currentPage: current,
          totalPages: pages,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('показывает число найденных патентов и номер страницы', (
    tester,
  ) async {
    await pumpHeader(tester, total: 25, current: 1, pages: 3);
    expect(find.text('Найдено патентов'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('стр. 2 из 3'), findsOneWidget);
  });

  testWidgets('при одной странице номер страницы скрыт', (tester) async {
    await pumpHeader(tester, total: 5, current: 0, pages: 1);
    expect(find.text('Найдено патентов'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.textContaining('стр.'), findsNothing);
  });

  testWidgets('при пустой выдаче номер страницы скрыт', (tester) async {
    await pumpHeader(tester, total: 0, current: 0, pages: 0);
    expect(find.text('Найдено патентов'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.textContaining('стр.'), findsNothing);
  });
}

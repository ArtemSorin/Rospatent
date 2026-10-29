import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/presentation/widgets/results/patent_card.dart';
import 'package:tag_highlight_text/tag_highlight_text.dart';

import '../../../helpers/test_data.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  testWidgets('показывает название, описание и данные патента', (tester) async {
    await tester.pumpWidget(host(PatentCard(patent: makeSummary(), onTap: () {})));

    expect(find.byType(TagHighlightText), findsNWidgets(2));
    expect(find.text('Автор: Иванов И.И., Петров П.П.'), findsOneWidget);
    expect(find.text('Язык: ru'), findsOneWidget);
    expect(find.text('МПК: G06F 17/30'), findsOneWidget);
  });

  testWidgets('слова в <em> подсвечиваются отдельными плашками', (tester) async {
    await tester.pumpWidget(host(PatentCard(
      patent: makeSummary(title: 'Способ <em>обработки</em> данных', description: 'Описание <em>способа</em>'),
      onTap: () {},
    )));
    expect(find.text('обработки'), findsOneWidget);
    expect(find.text('способа'), findsOneWidget);

    // плашки: у названия жирный шрифт, у описания обычный
    final title = tester.widget<Text>(find.text('обработки'));
    final description = tester.widget<Text>(find.text('способа'));
    expect(title.style!.fontWeight, FontWeight.bold);
    expect(description.style!.fontWeight, FontWeight.normal);
    expect(title.style!.color, Colors.white);
  });

  testWidgets('теги, кроме <em>, не создают плашек и не ломают карточку', (tester) async {
    await tester.pumpWidget(host(PatentCard(
      patent: makeSummary(title: 'Название <b>жирное</b>', description: 'Текст <i>курсив</i>'),
      onTap: () {},
    )));
    expect(tester.takeException(), isNull);
    expect(find.byType(PatentCard), findsOneWidget);
  });

  testWidgets('пустые поля не выводятся', (tester) async {
    await tester.pumpWidget(host(PatentCard(
      patent: makeSummary(inventors: '', lang: '', ipc: ''),
      onTap: () {},
    )));
    expect(find.textContaining('Автор:'), findsNothing);
    expect(find.textContaining('Язык:'), findsNothing);
    expect(find.textContaining('МПК:'), findsNothing);
  });

  testWidgets('поля из одних пробелов тоже скрываются', (tester) async {
    await tester.pumpWidget(host(PatentCard(
      patent: makeSummary(inventors: '   ', lang: ' ', ipc: '  '),
      onTap: () {},
    )));
    expect(find.textContaining('Автор:'), findsNothing);
  });

  testWidgets('нажатие вызывает onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(PatentCard(patent: makeSummary(), onTap: () => taps++)));
    await tester.tap(find.byType(InkWell).first);
    expect(taps, 1);
  });
}

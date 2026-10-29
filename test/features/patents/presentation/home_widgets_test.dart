import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/presentation/widgets/home/date_picker_row.dart';
import 'package:rospatent/features/patents/presentation/widgets/home/search_button.dart';
import 'package:rospatent/features/patents/presentation/widgets/home/search_input.dart';
import 'package:rospatent/features/patents/presentation/widgets/home/sort_section.dart';
import 'package:rospatent/features/patents/presentation/widgets/home/text_fields_section.dart';


Widget host(Widget child) => MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

void main() {
  group('SearchInput', () {
    testWidgets('показывает подсказку и иконку поиска', (tester) async {
      await tester.pumpWidget(host(SearchInput(controller: TextEditingController())));
      expect(find.text('Поиск по тексту'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('пишет введённый текст в контроллер', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(host(SearchInput(controller: controller)));
      await tester.enterText(find.byType(TextField), 'робот');
      expect(controller.text, 'робот');
    });

    testWidgets('действие «поиск» на клавиатуре вызывает onSubmitted', (tester) async {
      var submitted = 0;
      await tester.pumpWidget(host(SearchInput(
        controller: TextEditingController(),
        onSubmitted: () => submitted++,
      )));
      await tester.showKeyboard(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(submitted, 1);
    });

    testWidgets('без onSubmitted ничего не ломается', (tester) async {
      await tester.pumpWidget(host(SearchInput(controller: TextEditingController())));
      await tester.showKeyboard(find.byType(TextField));
      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(tester.takeException(), isNull);
    });
  });

  group('SearchButton', () {
    testWidgets('показывает текст и реагирует на нажатие', (tester) async {
      var taps = 0;
      await tester.pumpWidget(host(SearchButton(onPressed: () => taps++)));
      expect(find.text('Поиск'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(taps, 1);
    });
  });

  group('SortSection', () {
    testWidgets('показывает заголовок и выбранный вариант', (tester) async {
      await tester.pumpWidget(host(SortSection(value: SortOrder.relevance, onChanged: (_) {})));
      expect(find.text('Сортировка'), findsOneWidget);
      expect(find.text('Релевантности'), findsOneWidget);
      expect(find.byIcon(Icons.sort), findsOneWidget);
    });

    testWidgets('отображает значение, переданное снаружи', (tester) async {
      await tester.pumpWidget(host(SortSection(value: SortOrder.filingDesc, onChanged: (_) {})));
      expect(find.text('Дате регистрации ↓'), findsOneWidget);
    });

    testWidgets('в выпадающем списке все 5 вариантов', (tester) async {
      await tester.pumpWidget(host(SortSection(value: SortOrder.relevance, onChanged: (_) {})));
      await tester.tap(find.byType(DropdownButtonFormField<SortOrder>));
      await tester.pumpAndSettle();
      for (final label in [
        'Релевантности',
        'Дате публикации ↑',
        'Дате публикации ↓',
        'Дате регистрации ↑',
        'Дате регистрации ↓',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('выбор варианта вызывает onChanged', (tester) async {
      SortOrder? changed;
      await tester.pumpWidget(host(SortSection(value: SortOrder.relevance, onChanged: (v) => changed = v)));
      await tester.tap(find.byType(DropdownButtonFormField<SortOrder>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Дате регистрации ↑').last);
      await tester.pumpAndSettle();
      expect(changed, SortOrder.filingAsc);
    });
  });

  group('DatePickerRow', () {
    Widget build({
      DateTime? from,
      DateTime? to,
      VoidCallback? onPickFrom,
      VoidCallback? onPickTo,
      VoidCallback? onClearFrom,
      VoidCallback? onClearTo,
    }) => host(DatePickerRow(
      from: from,
      to: to,
      onPickFrom: onPickFrom ?? () {},
      onPickTo: onPickTo ?? () {},
      onClearFrom: onClearFrom ?? () {},
      onClearTo: onClearTo ?? () {},
    ));

    testWidgets('без дат показывает «Не выбрана» и нет кнопок сброса', (tester) async {
      await tester.pumpWidget(build());
      expect(find.text('Дата публикации'), findsOneWidget);
      expect(find.text('Публикация от'), findsOneWidget);
      expect(find.text('Публикация до'), findsOneWidget);
      expect(find.text('Не выбрана'), findsNWidgets(2));
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('выбранные даты форматируются как дд.мм.гггг', (tester) async {
      await tester.pumpWidget(build(from: DateTime(2019, 1, 5), to: DateTime(2020, 12, 31)));
      expect(find.text('05.01.2019'), findsOneWidget);
      expect(find.text('31.12.2020'), findsOneWidget);
      expect(find.text('Не выбрана'), findsNothing);
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });

    testWidgets('нажатие на поля вызывает выбор даты', (tester) async {
      var from = 0, to = 0;
      await tester.pumpWidget(build(onPickFrom: () => from++, onPickTo: () => to++));
      await tester.tap(find.text('Не выбрана').first);
      await tester.tap(find.text('Не выбрана').last);
      expect(from, 1);
      expect(to, 1);
    });

    testWidgets('кнопки сброса вызывают свои колбэки', (tester) async {
      var clearFrom = 0, clearTo = 0;
      await tester.pumpWidget(build(
        from: DateTime(2019, 1, 5),
        to: DateTime(2020, 12, 31),
        onClearFrom: () => clearFrom++,
        onClearTo: () => clearTo++,
      ));
      await tester.tap(find.byIcon(Icons.close).first);
      expect(clearFrom, 1);
      expect(clearTo, 0);
      await tester.tap(find.byIcon(Icons.close).last);
      expect(clearTo, 1);
    });

    testWidgets('сброс есть только у выбранной даты', (tester) async {
      await tester.pumpWidget(build(from: DateTime(2019, 1, 5)));
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Не выбрана'), findsOneWidget);
    });
  });

  group('TextFieldsSection', () {
    testWidgets('три поля с подсказками', (tester) async {
      await tester.pumpWidget(host(TextFieldsSection(
        patenteeController: TextEditingController(),
        authorsController: TextEditingController(),
      )));
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.text('Номер заявки'), findsOneWidget);
      expect(find.text('Авторы (ФИО через запятую)'), findsOneWidget);
      expect(find.text('Патентообладатели (ФИО через запятую)'), findsOneWidget);
    });

    testWidgets('поля авторов и патентообладателей пишут в свои контроллеры', (tester) async {
      final patentee = TextEditingController();
      final authors = TextEditingController();
      await tester.pumpWidget(host(TextFieldsSection(patenteeController: patentee, authorsController: authors)));
      await tester.enterText(find.byType(TextField).at(1), 'Иванов И.И.');
      await tester.enterText(find.byType(TextField).at(2), 'ООО Ромашка');
      expect(authors.text, 'Иванов И.И.');
      expect(patentee.text, 'ООО Ромашка');
    });
  });
}

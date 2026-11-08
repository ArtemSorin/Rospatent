import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:rospatent/core/error/failure.dart';
import 'package:rospatent/core/theme/app_colors.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/presentation/screens/patent_details_screen.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump.dart';
import '../../../helpers/test_data.dart';

void main() {
  late FakePatentRepository patents;
  late InMemoryFavoritesRepository favorites;

  Future<void> openDetails(
    WidgetTester tester, {
    hint,
    String id = 'RU2701234C1_20190925',
  }) async {
    useTallScreen(tester);
    await pumpScoped(
      tester,
      PatentDetailsPage(patentId: id, hint: hint),
      deps: buildDeps(patents: patents, favorites: favorites),
    );
  }

  setUp(() {
    patents = FakePatentRepository();
    favorites = InMemoryFavoritesRepository();
  });

  group('загрузка', () {
    testWidgets('пока документ грузится: индикатор и недоступная звезда', (
      tester,
    ) async {
      final gate = Completer<PatentDetails>();
      patents.detailsHandler = (id) => gate.future;
      await openDetails(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final star = tester.widget<AppBarButton>(
        find.widgetWithIcon(AppBarButton, Icons.star_outline_rounded),
      );
      expect(star.onPressed, isNull);

      gate.complete(makeDetails());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('ошибка: сообщение, повтор загружает документ', (tester) async {
      patents.detailsHandler = (id) => Future.error(const NetworkFailure());
      await openDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Не удалось загрузить патент'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      patents.detailsHandler = null;
      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();
      expect(find.text('Способ обработки данных'), findsOneWidget);
      expect(find.text('Не удалось загрузить патент'), findsNothing);
    });

    testWidgets('запрашивает документ по id', (tester) async {
      await openDetails(tester, id: 'RU42C1_20200101');
      await tester.pumpAndSettle();
      expect(patents.detailsCalls, ['RU42C1_20200101']);
    });
  });

  group('содержимое', () {
    testWidgets('показывает все разделы и данные патента', (tester) async {
      await openDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Выбранный патент'), findsOneWidget);
      expect(find.text('Способ обработки данных'), findsOneWidget);
      expect(find.text('Патент на изобретение'), findsOneWidget);

      for (final section in [
        'Авторы',
        'Патентообладатели',
        'Заявитель',
        'Номер заявки',
        'Публикация',
        'Дата подачи',
        'Дата публикации',
        'МПК',
        'CPC',
        'Идентификатор',
        'Реферат',
        'Формула',
        'Описание',
      ]) {
        expect(find.text(section), findsOneWidget, reason: section);
      }

      expect(find.text('Иванов И.И.'), findsOneWidget);
      expect(find.text('Петров П.П.'), findsOneWidget);
      expect(find.text('ООО Ромашка'), findsOneWidget);
      expect(find.text('ООО Заявитель'), findsOneWidget);
      expect(find.text('2018111222'), findsOneWidget);
      expect(find.text('RU 2701234 C1'), findsWidgets);
      expect(find.text('28.03.2018'), findsOneWidget);
      expect(find.text('25.09.2019'), findsOneWidget);
      expect(find.text('G06F 17/30'), findsOneWidget);
      expect(find.text('G06N 3/00'), findsOneWidget);
      expect(find.text('RU2701234C1_20190925'), findsOneWidget);
    });

    testWidgets('реферат, формула и описание отображаются как HTML', (
      tester,
    ) async {
      await openDetails(tester);
      await tester.pumpAndSettle();
      expect(find.byType(HtmlWidget), findsOneWidget);
      expect(find.text('Нет данных'), findsNothing);
    });

    testWidgets('отсутствующие данные заменяются заглушками', (tester) async {
      patents.detailsHandler = (id) async => PatentDetails(id: id);
      await openDetails(tester);
      await tester.pumpAndSettle();

      expect(find.text('Без названия'), findsOneWidget);
      // авторы, патентообладатели, реферат, формула, описание
      expect(find.text('Нет данных'), findsNWidgets(5));
      expect(find.byType(HtmlWidget), findsNothing);
      // номер заявки, публикация, обе даты
      expect(find.text('—'), findsNWidgets(4));
      // необязательные разделы скрыты
      expect(find.text('Заявитель'), findsNothing);
      expect(find.text('МПК и CPC'), findsNothing);
      expect(find.text('Патент на изобретение'), findsNothing);
    });

    testWidgets(
      'МПК и CPC показываются, даже если заполнено только одно поле',
      (tester) async {
        patents.detailsHandler = (id) async => makeDetails(id: id, cpc: '');
        await openDetails(tester);
        await tester.pumpAndSettle();
        expect(find.text('МПК'), findsOneWidget);
        expect(find.text('G06F 17/30'), findsOneWidget);
      },
    );

    testWidgets('авторы и патентообладатели добираются из списка поиска', (
      tester,
    ) async {
      patents.detailsHandler = (id) async => makeDetails(
        id: id,
        title: '',
        inventors: const [],
        patentees: const [],
        applicant: '',
      );
      await openDetails(
        tester,
        hint: makeSummary(
          title: 'Из <em>поиска</em>',
          inventors: 'Сидоров С.С., Орлов О.О.',
          patentees: 'ИП Кузнецов',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Из поиска'), findsOneWidget);
      expect(find.text('Сидоров С.С.'), findsOneWidget);
      expect(find.text('Орлов О.О.'), findsOneWidget);
      expect(find.text('ИП Кузнецов'), findsOneWidget);
    });
  });

  group('избранное', () {
    testWidgets('звезда добавляет и убирает патент', (tester) async {
      await openDetails(tester);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      expect(find.byTooltip('Добавить в избранное'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byTooltip('Убрать из избранного'), findsOneWidget);
      expect(favorites.store.keys.toList(), ['RU2701234C1_20190925']);
      expect(favorites.store.values.single.title, 'Способ обработки данных');

      await tester.tap(find.byIcon(Icons.star_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);
      expect(favorites.store, isEmpty);
    });

    testWidgets(
      'патент, уже лежащий в избранном, открывается с закрашенной звездой',
      (tester) async {
        favorites.store['RU2701234C1_20190925'] = makeFavorite();
        await openDetails(tester);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      },
    );

    testWidgets('цвет звезды: янтарный для избранного, серый для остальных', (
      tester,
    ) async {
      await openDetails(tester);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Icon>(find.byIcon(Icons.star_outline_rounded)).color,
        AppColors.brand,
      );
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Icon>(find.byIcon(Icons.star_rounded)).color,
        AppColors.amber,
      );
    });
  });

  testWidgets('кнопка «назад» закрывает экран', (tester) async {
    useTallScreen(tester);
    await pumpPushed(
      tester,
      () => const PatentDetailsPage(patentId: 'RU1C1_20200101'),
      deps: buildDeps(patents: patents, favorites: favorites),
    );
    await tester.pumpAndSettle();
    expect(find.text('Выбранный патент'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Выбранный патент'), findsNothing);
  });
}

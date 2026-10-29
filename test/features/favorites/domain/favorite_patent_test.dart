import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';

import '../../../helpers/test_data.dart';

void main() {
  group('FavoritePatent.fromDetails', () {
    test('переносит идентификаторы и чистит текст от HTML', () {
      final now = DateTime(2024, 5, 6);
      final f = FavoritePatent.fromDetails(
        makeDetails(title: '<em>Способ</em> X', applicant: '<b>ООО</b> Я', ipc: '<em>G06F</em> 1/00', cpc: 'H04L'),
        now: now,
      );
      expect(f.id, 'RU2701234C1_20190925');
      expect(f.title, 'Способ X');
      expect(f.applicant, 'ООО Я');
      expect(f.ipc, 'G06F 1/00');
      expect(f.cpc, 'H04L');
      expect(f.applicationNumber, '2018111222');
      expect(f.documentNumber, 2701234);
      expect(f.kind, 'C1');
      expect(f.guid, 'guid-1');
      expect(f.country, 'RU');
      expect(f.publicationDate, DateTime(2019, 9, 25));
      expect(f.filingDate, DateTime(2018, 3, 28));
      expect(f.addedAt, now);
    });

    test('авторы и патентообладатели склеиваются через запятую', () {
      final f = FavoritePatent.fromDetails(makeDetails(
        inventors: const ['А', 'Б'], patentees: const ['В', 'Г'],
      ));
      expect(f.inventors, 'А, Б');
      expect(f.patentees, 'В, Г');
    });

    test('описание берётся из описания, а при его отсутствии — из реферата', () {
      expect(
        FavoritePatent.fromDetails(makeDetails(descriptionHtml: '<p>Описание</p>', abstractHtml: '<p>Реферат</p>')).description,
        'Описание',
      );
      expect(
        FavoritePatent.fromDetails(makeDetails(descriptionHtml: '', abstractHtml: '<p>Реферат</p>')).description,
        'Реферат',
      );
      expect(
        FavoritePatent.fromDetails(makeDetails(descriptionHtml: '', abstractHtml: '')).description,
        '',
      );
    });

    test('длинное описание обрезается до ~400 символов с многоточием', () {
      final f = FavoritePatent.fromDetails(makeDetails(descriptionHtml: '<p>${'слово ' * 200}</p>'));
      expect(f.description.length, lessThanOrEqualTo(401));
      expect(f.description.endsWith('…'), isTrue);
    });

    test('addedAt по умолчанию — текущее время', () {
      final before = DateTime.now();
      final f = FavoritePatent.fromDetails(makeDetails());
      expect(f.addedAt.isBefore(before), isFalse);
    });

    test('даты и номер документа могут отсутствовать', () {
      final f = FavoritePatent.fromDetails(const PatentDetails(id: 'x'));
      expect(f.documentNumber, isNull);
      expect(f.publicationDate, isNull);
      expect(f.filingDate, isNull);
    });
  });

  group('FavoritePatent.toSummary', () {
    test('превращается в краткое описание для открытия экрана патента', () {
      final s = makeFavorite().toSummary();
      expect(s.id, 'RU2701234C1_20190925');
      expect(s.title, 'Способ обработки данных');
      expect(s.description, 'Краткое описание патента');
      expect(s.applicant, 'ООО Заявитель');
      expect(s.inventors, 'Иванов И.И., Петров П.П.');
      expect(s.patentees, 'ООО Ромашка');
      expect(s.ipc, 'G06F 17/30');
      expect(s.cpc, 'G06N 3/00');
    });
  });
}

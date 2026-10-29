import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/favorites/data/models/favorite_patent_model.dart';
import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';

import '../../../helpers/test_data.dart';

void main() {
  group('FavoritePatentModel.toMap', () {
    test('содержит все колонки таблицы', () {
      final map = FavoritePatentModel.toMap(makeFavorite(addedAt: DateTime.fromMillisecondsSinceEpoch(1000)));
      expect(map, {
        'id': 'RU2701234C1_20190925',
        'title': 'Способ обработки данных',
        'description': 'Краткое описание патента',
        'application_number': '2018111222',
        'document_number': 2701234,
        'kind': 'C1',
        'guid': 'guid-1',
        'country': 'RU',
        'lang': '',
        'ipc': 'G06F 17/30',
        'cpc': 'G06N 3/00',
        'inventor': 'Иванов И.И., Петров П.П.',
        'patentee': 'ООО Ромашка',
        'applicant': 'ООО Заявитель',
        'publication_date': DateTime(2019, 9, 25).toIso8601String(),
        'filing_date': DateTime(2018, 3, 28).toIso8601String(),
        'added_at': 1000,
      });
    });

    test('отсутствующий номер документа сохраняется как -1, даты как null', () {
      final map = FavoritePatentModel.toMap(FavoritePatent(
        id: 'x',
        title: 'T',
        addedAt: DateTime(2024),
      ));
      expect(map['document_number'], -1);
      expect(map['publication_date'], isNull);
      expect(map['filing_date'], isNull);
    });
  });

  group('FavoritePatentModel.fromMap', () {
    test('круговое преобразование не теряет данные', () {
      final original = makeFavorite(addedAt: DateTime.fromMillisecondsSinceEpoch(5000));
      final back = FavoritePatentModel.fromMap(FavoritePatentModel.toMap(original));
      expect(back.id, original.id);
      expect(back.title, original.title);
      expect(back.description, original.description);
      expect(back.applicationNumber, original.applicationNumber);
      expect(back.documentNumber, original.documentNumber);
      expect(back.kind, original.kind);
      expect(back.guid, original.guid);
      expect(back.country, original.country);
      expect(back.ipc, original.ipc);
      expect(back.cpc, original.cpc);
      expect(back.inventors, original.inventors);
      expect(back.patentees, original.patentees);
      expect(back.applicant, original.applicant);
      expect(back.publicationDate, original.publicationDate);
      expect(back.filingDate, original.filingDate);
      expect(back.addedAt, original.addedAt);
    });

    test('номер документа -1 и отсутствующий превращаются в null', () {
      expect(FavoritePatentModel.fromMap({'id': 'x', 'document_number': -1}).documentNumber, isNull);
      expect(FavoritePatentModel.fromMap({'id': 'x'}).documentNumber, isNull);
      expect(FavoritePatentModel.fromMap({'id': 'x', 'document_number': 5}).documentNumber, 5);
    });

    test('отсутствующие текстовые поля становятся пустыми строками', () {
      final f = FavoritePatentModel.fromMap({'id': 'x'});
      for (final v in [
        f.title, f.description, f.applicationNumber, f.kind, f.guid,
        f.country, f.ipc, f.cpc, f.inventors, f.patentees, f.applicant,
      ]) {
        expect(v, '');
      }
    });

    test('даты: null и мусор дают null', () {
      final f = FavoritePatentModel.fromMap({'id': 'x', 'publication_date': null, 'filing_date': 'не дата'});
      expect(f.publicationDate, isNull);
      expect(f.filingDate, isNull);
    });

    test('added_at по умолчанию — начало эпохи', () {
      expect(FavoritePatentModel.fromMap({'id': 'x'}).addedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });
}

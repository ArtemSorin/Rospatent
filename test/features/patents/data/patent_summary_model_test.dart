import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/data/models/patent_summary_model.dart';

import '../../../helpers/test_data.dart';

void main() {
  group('PatentSummaryModel.fromHit', () {
    test('разбирает полную находку', () {
      final hit = (searchJson()['hits'] as List).first as Map<String, dynamic>;
      final s = PatentSummaryModel.fromHit(hit);
      expect(s.id, 'RU1C1_20200101');
      expect(s.title, '<em>Т</em>1');
      expect(s.description, 'описание 1');
      expect(s.lang, 'ru');
      expect(s.applicant, 'Заявитель 1');
      expect(s.inventors, 'Иванов И.И.');
      expect(s.patentees, 'ООО Один');
      expect(s.ipc, 'G06F 1/00');
      expect(s.cpc, 'H04L 1/00, H04L 2/00');
    });

    test('неполная находка — недостающие поля пустые', () {
      final hit = (searchJson()['hits'] as List).last as Map<String, dynamic>;
      final s = PatentSummaryModel.fromHit(hit);
      expect(s.id, 'RU2U1_20210202');
      expect(s.title, 'Т2');
      expect(s.description, '');
      expect(s.inventors, '');
      expect(s.ipc, '');
      expect(s.cpc, '');
    });

    test('без snippet и с «битой» классификацией не падает', () {
      final s = PatentSummaryModel.fromHit({'id': 'x', 'snippet': 'мусор'});
      expect(s.id, 'x');
      expect(s.title, '');

      final s2 = PatentSummaryModel.fromHit({'id': 'y', 'snippet': {'classification': 'мусор'}});
      expect(s2.ipc, '');
      expect(s2.cpc, '');
    });

    test('авторы списком склеиваются через запятую', () {
      final s = PatentSummaryModel.fromHit({
        'id': 'z',
        'snippet': {'inventor': ['А', 'Б']},
      });
      expect(s.inventors, 'А, Б');
    });

    test('пустая находка', () {
      expect(PatentSummaryModel.fromHit({}).id, '');
    });
  });
}

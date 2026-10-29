import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/data/models/patent_details_model.dart';

import '../../../helpers/test_data.dart';

void main() {
  group('каноничный ответ (язык -> значение)', () {
    test('разбирает все поля', () {
      final d = PatentDetailsModel.fromJson(docJson(), fallbackId: 'fb');
      expect(d.id, 'RU2701234C1_20190925');
      expect(d.title, 'Способ');
      expect(d.applicationNumber, '2018111222');
      expect(d.documentNumber, 2701234);
      expect(d.kind, 'C1');
      expect(d.guid, 'guid-1');
      expect(d.country, 'RU');
      expect(d.publicationDate, DateTime(2019, 9, 25));
      expect(d.filingDate, DateTime(2018, 3, 28));
      expect(d.inventors, ['Иванов И.И.', 'Петров П.П.']);
      expect(d.patentees, ['ООО Ромашка']);
      expect(d.applicant, 'ООО Заявитель');
      expect(d.ipc, 'G06F 17/30');
      expect(d.cpc, 'G06N 3/00');
      expect(d.abstractHtml, '<p>Реферат</p>');
      expect(d.claimsHtml, '<p>1. Способ</p>');
      expect(d.descriptionHtml, '<p>Описание</p>');
    });
  });

  group('нестандартные формы ответа', () {
    test('реферат списком [{lang,text}], формула строкой, описание объектом', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {
          'ru': {'title': 'T', 'inventor': ['Сидоров С.С.'], 'patentee': 'ООО Тест'},
        },
        'abstract': [
          {'lang': 'en', 'text': 'EN'},
          {'lang': 'ru', 'text': 'РУ реферат'},
        ],
        'claims': '<p>формула строкой</p>',
        'description': {'ru': {'text': '<p>описание объектом</p>'}},
      }, fallbackId: 'fb');
      expect(d.abstractHtml, 'РУ реферат');
      expect(d.claimsHtml, '<p>формула строкой</p>');
      expect(d.descriptionHtml, '<p>описание объектом</p>');
      expect(d.inventors, ['Сидоров С.С.']);
      expect(d.patentees, ['ООО Тест']);
    });

    test('нет русского — берутся данные другого языка', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {'en': {'title': 'Only EN', 'inventor': [{'name': 'John'}]}},
        'abstract': {'en': 'EN only'},
      }, fallbackId: 'c');
      expect(d.title, 'Only EN');
      expect(d.abstractHtml, 'EN only');
      expect(d.inventors, ['John']);
    });

    test('русский блок без авторов — авторы берутся из другого блока', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {
          'ru': {'title': 'Т'},
          'en': {'inventor': [{'name': 'John'}]},
        },
      }, fallbackId: 'x');
      expect(d.title, 'Т');
      expect(d.inventors, ['John']);
    });

    test('«плоский» biblio без разбивки по языкам', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {'title': 'Плоский', 'inventor': [{'name': 'А'}]},
      }, fallbackId: 'x');
      expect(d.title, 'Плоский');
      expect(d.inventors, ['А']);
    });

    test('«плоский» biblio, определяемый по полю inventor', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {'inventor': [{'name': 'А'}]},
      }, fallbackId: 'x');
      expect(d.inventors, ['А']);
    });

    test('biblio не словарь — блоки пусты', () {
      final d = PatentDetailsModel.fromJson({'biblio': 'мусор'}, fallbackId: 'x');
      expect(d.title, '');
      expect(d.inventors, isEmpty);
    });

    test('значения-не-словари внутри biblio пропускаются', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {'ru': 'не словарь', 'en': {'title': 'T'}},
      }, fallbackId: 'x');
      expect(d.title, 'T');
    });

    test('заявитель собирается из списка', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {'ru': {'applicant': [{'name': 'А'}, {'name': 'Б'}]}},
      }, fallbackId: 'x');
      expect(d.applicant, 'А, Б');
    });

    test('альтернативные ключи авторов и патентообладателей', () {
      final d = PatentDetailsModel.fromJson({
        'biblio': {'ru': {'authors': ['А'], 'patent_holders': ['Б']}},
      }, fallbackId: 'x');
      expect(d.inventors, ['А']);
      expect(d.patentees, ['Б']);
    });
  });

  group('служебные поля', () {
    test('id берётся из ответа', () {
      expect(PatentDetailsModel.fromJson({'id': 'real'}, fallbackId: 'fb').id, 'real');
    });
    test('id подставляется, если его нет или он пустой', () {
      expect(PatentDetailsModel.fromJson({}, fallbackId: 'fb').id, 'fb');
      expect(PatentDetailsModel.fromJson({'id': ''}, fallbackId: 'fb').id, 'fb');
    });
    test('номер документа может быть числом', () {
      final d = PatentDetailsModel.fromJson({'common': {'document_number': 2701234}}, fallbackId: 'x');
      expect(d.documentNumber, 2701234);
    });
    test('некорректный номер документа -> null', () {
      final d = PatentDetailsModel.fromJson({'common': {'document_number': 'abc'}}, fallbackId: 'x');
      expect(d.documentNumber, isNull);
    });
    test('пустой ответ не падает и даёт пустые поля', () {
      final d = PatentDetailsModel.fromJson({}, fallbackId: 'e');
      expect(d.id, 'e');
      expect(d.title, '');
      expect(d.abstractHtml, '');
      expect(d.claimsHtml, '');
      expect(d.descriptionHtml, '');
      expect(d.publicationDate, isNull);
      expect(d.filingDate, isNull);
      expect(d.applicationNumber, '');
      expect(d.ipc, '');
    });
    test('хотя бы одно текстовое поле заполнено — всё разбирается без ошибок', () {
      final d = PatentDetailsModel.fromJson({'abstract': {'ru': 'x'}}, fallbackId: 'x');
      expect(d.abstractHtml, 'x');
    });
  });
}

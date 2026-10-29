import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/domain/entities/document_kind.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../../../helpers/test_data.dart';

void main() {
  group('PatentSummary', () {
    test('значения по умолчанию — пустые строки', () {
      const s = PatentSummary(id: 'id');
      expect(s.id, 'id');
      for (final value in [
        s.title, s.description, s.lang, s.applicant,
        s.inventors, s.patentees, s.ipc, s.cpc,
      ]) {
        expect(value, '');
      }
    });
  });

  group('SearchQuery', () {
    test('значения по умолчанию', () {
      const q = SearchQuery();
      expect(q.text, '');
      expect(q.patentees, isEmpty);
      expect(q.authors, isEmpty);
      expect(q.sort, SortOrder.relevance);
      expect(q.publishedFrom, isNull);
      expect(q.publishedTo, isNull);
    });

    test('хранит переданные значения', () {
      final q = SearchQuery(
        text: 'робот',
        patentees: const ['ООО А'],
        authors: const ['Иванов'],
        sort: SortOrder.filingDesc,
        publishedFrom: DateTime(2019),
        publishedTo: DateTime(2020),
      );
      expect(q.text, 'робот');
      expect(q.patentees, ['ООО А']);
      expect(q.authors, ['Иванов']);
      expect(q.sort, SortOrder.filingDesc);
      expect(q.publishedFrom, DateTime(2019));
      expect(q.publishedTo, DateTime(2020));
    });

    test('SortOrder содержит все 5 вариантов в нужном порядке', () {
      expect(SortOrder.values, [
        SortOrder.relevance,
        SortOrder.publicationAsc,
        SortOrder.publicationDesc,
        SortOrder.filingAsc,
        SortOrder.filingDesc,
      ]);
    });
  });

  group('SearchPage.totalPages', () {
    SearchPage page(int total, int size) =>
        SearchPage(items: const [], total: total, page: 0, pageSize: size);

    test('0 результатов — 0 страниц', () {
      expect(page(0, 10).totalPages, 0);
    });

    test('отрицательный total — 0 страниц', () {
      expect(page(-5, 10).totalPages, 0);
    });

    test('неполная последняя страница учитывается', () {
      expect(page(25, 10).totalPages, 3);
      expect(page(1, 10).totalPages, 1);
      expect(page(11, 10).totalPages, 2);
    });

    test('кратное число результатов', () {
      expect(page(20, 10).totalPages, 2);
      expect(page(10, 10).totalPages, 1);
    });

    test('размер страницы 1', () {
      expect(page(7, 1).totalPages, 7);
    });

    test('хранит элементы, номер страницы и размер', () {
      final p = makePage(total: 25, page: 1, pageSize: 10);
      expect(p.items.length, 10);
      expect(p.page, 1);
      expect(p.pageSize, 10);
      expect(p.total, 25);
    });
  });

  group('documentKindLabel', () {
    test('пустой код', () => expect(documentKindLabel(''), 'Документ'));
    test('заявка (A)', () {
      expect(documentKindLabel('A'), 'Заявка на изобретение');
      expect(documentKindLabel('A1'), 'Заявка на изобретение');
    });
    test('патент на изобретение (C1/C2)', () {
      expect(documentKindLabel('C1'), 'Патент на изобретение');
      expect(documentKindLabel('C2'), 'Патент на изобретение');
    });
    test('полезная модель (U1)', () => expect(documentKindLabel('U1'), 'Полезная модель'));
    test('промышленный образец (S1)', () => expect(documentKindLabel('S1'), 'Промышленный образец'));
    test('регистр не важен', () => expect(documentKindLabel('c1'), 'Патент на изобретение'));
    test('неизвестный код выводится как есть', () {
      expect(documentKindLabel('B1'), 'Документ B1');
    });
  });

  group('PatentDetails', () {
    test('значения по умолчанию', () {
      const d = PatentDetails(id: 'x');
      expect(d.title, '');
      expect(d.documentNumber, isNull);
      expect(d.inventors, isEmpty);
      expect(d.patentees, isEmpty);
      expect(d.publicationDate, isNull);
      expect(d.filingDate, isNull);
      expect(d.abstractHtml, '');
      expect(d.claimsHtml, '');
      expect(d.descriptionHtml, '');
    });

    group('withFallback', () {
      test('без подсказки возвращает тот же объект', () {
        const d = PatentDetails(id: 'x');
        expect(identical(d.withFallback(null), d), isTrue);
      });

      test('заполняет пустые поля из списка поиска и чистит HTML', () {
        const d = PatentDetails(id: 'x');
        final r = d.withFallback(makeSummary(
          title: 'Способ <em>X</em>',
          applicant: '<em>ООО</em> Заявитель',
          inventors: 'Иванов И.И., Петров П.П.',
          patentees: 'ООО Ромашка; ИП Сидоров',
          ipc: '<em>G06F</em> 1/00',
          cpc: 'H04L 1/00',
        ));
        expect(r.id, 'x');
        expect(r.title, 'Способ X');
        expect(r.applicant, 'ООО Заявитель');
        expect(r.inventors, ['Иванов И.И.', 'Петров П.П.']);
        expect(r.patentees, ['ООО Ромашка', 'ИП Сидоров']);
        expect(r.ipc, 'G06F 1/00');
        expect(r.cpc, 'H04L 1/00');
      });

      test('не затирает уже заполненные поля', () {
        final d = makeDetails();
        final r = d.withFallback(makeSummary(
          title: 'Другое', applicant: 'Другой', inventors: 'Кто-то',
          patentees: 'Другие', ipc: 'A61K 1/00', cpc: 'A61K 2/00',
        ));
        expect(r.title, d.title);
        expect(r.applicant, d.applicant);
        expect(r.inventors, d.inventors);
        expect(r.patentees, d.patentees);
        expect(r.ipc, d.ipc);
        expect(r.cpc, d.cpc);
      });

      test('сохраняет остальные поля документа без изменений', () {
        final d = makeDetails();
        final r = d.withFallback(makeSummary());
        expect(r.applicationNumber, d.applicationNumber);
        expect(r.documentNumber, d.documentNumber);
        expect(r.kind, d.kind);
        expect(r.guid, d.guid);
        expect(r.country, d.country);
        expect(r.publicationDate, d.publicationDate);
        expect(r.filingDate, d.filingDate);
        expect(r.abstractHtml, d.abstractHtml);
        expect(r.claimsHtml, d.claimsHtml);
        expect(r.descriptionHtml, d.descriptionHtml);
      });
    });
  });
}

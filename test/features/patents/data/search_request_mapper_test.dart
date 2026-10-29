import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/data/models/search_request_mapper.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

void main() {
  Map<String, dynamic> body(SearchQuery q, {int page = 0, int size = 10}) =>
      SearchRequestMapper.toBody(q, page: page, pageSize: size);

  group('базовые поля', () {
    test('пустой запрос', () {
      expect(body(const SearchQuery()), {
        'qn': '',
        'limit': 10,
        'offset': 0,
        'sort': 'relevance',
        'include_facets': 0,
      });
    });

    test('текст попадает в qn', () {
      expect(body(const SearchQuery(text: 'робот'))['qn'], 'робот');
    });

    test('offset = страница * размер страницы', () {
      expect(body(const SearchQuery(), page: 3)['offset'], 30);
      expect(body(const SearchQuery(), page: 2, size: 100)['offset'], 200);
      expect(body(const SearchQuery(), page: 2, size: 100)['limit'], 100);
    });

    test('без фильтров ключа filter нет', () {
      expect(body(const SearchQuery()).containsKey('filter'), isFalse);
    });
  });

  group('сортировка', () {
    final expected = {
      SortOrder.relevance: 'relevance',
      SortOrder.publicationAsc: 'publication_date:asc',
      SortOrder.publicationDesc: 'publication_date:desc',
      SortOrder.filingAsc: 'filing_date:asc',
      SortOrder.filingDesc: 'filing_date:desc',
    };
    for (final entry in expected.entries) {
      test('${entry.key.name} -> ${entry.value}', () {
        expect(body(SearchQuery(sort: entry.key))['sort'], entry.value);
      });
    }
  });

  group('фильтры', () {
    test('авторы получают суффикс (RU)', () {
      final filter = body(const SearchQuery(authors: ['Иванов И.И.', 'Петров']))['filter'] as Map;
      expect(filter['authors'], {'values': ['Иванов И.И. (RU)', 'Петров (RU)']});
      expect(filter.containsKey('patent_holders'), isFalse);
    });

    test('патентообладатели', () {
      final filter = body(const SearchQuery(patentees: ['ООО А']))['filter'] as Map;
      expect(filter['patent_holders'], {'values': ['ООО А (RU)']});
      expect(filter.containsKey('authors'), isFalse);
    });

    test('обе границы дат в формате yyyyMMdd', () {
      final filter = body(SearchQuery(
        publishedFrom: DateTime(2019, 1, 5),
        publishedTo: DateTime(2020, 12, 31),
      ))['filter'] as Map;
      expect(filter['date_published'], {
        'range': {'gte': '20190105', 'lte': '20201231'},
      });
    });

    test('только нижняя граница', () {
      final filter = body(SearchQuery(publishedFrom: DateTime(2019, 1, 5)))['filter'] as Map;
      expect(filter['date_published'], {'range': {'gte': '20190105'}});
    });

    test('только верхняя граница', () {
      final filter = body(SearchQuery(publishedTo: DateTime(2020, 2, 3)))['filter'] as Map;
      expect(filter['date_published'], {'range': {'lte': '20200203'}});
    });

    test('год дополняется нулями до 4 цифр', () {
      final filter = body(SearchQuery(publishedFrom: DateTime(987, 3, 4)))['filter'] as Map;
      expect((filter['date_published'] as Map)['range'], {'gte': '09870304'});
    });

    test('все фильтры вместе и тело сериализуется в JSON', () {
      final b = body(SearchQuery(
        text: 'x',
        authors: const ['А'],
        patentees: const ['Б'],
        publishedFrom: DateTime(2020, 1, 1),
        publishedTo: DateTime(2021, 1, 1),
      ));
      final filter = b['filter'] as Map;
      expect(filter.keys, containsAll(['authors', 'patent_holders', 'date_published']));
      expect(jsonDecode(jsonEncode(b)), b);
    });
  });
}

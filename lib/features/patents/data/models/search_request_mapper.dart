import 'package:rospatent/features/patents/domain/entities/search_query.dart';

/// Превращает доменный [SearchQuery] в тело запроса к /search.
class SearchRequestMapper {
  const SearchRequestMapper._(); // coverage:ignore-line

  static Map<String, dynamic> toBody(
    SearchQuery query, {
    required int page,
    required int pageSize,
  }) {
    final body = <String, dynamic>{
      'qn': query.text,
      'limit': pageSize,
      'offset': page * pageSize,
      'sort': _sort(query.sort),
      'include_facets': 0,
    };

    final filter = <String, dynamic>{};
    if (query.authors.isNotEmpty) {
      filter['authors'] = {
        'values': query.authors.map((a) => '$a (RU)').toList(),
      };
    }
    if (query.patentees.isNotEmpty) {
      filter['patent_holders'] = {
        'values': query.patentees.map((p) => '$p (RU)').toList(),
      };
    }
    final range = <String, String>{};
    if (query.publishedFrom != null) range['gte'] = _date(query.publishedFrom!);
    if (query.publishedTo != null) range['lte'] = _date(query.publishedTo!);
    if (range.isNotEmpty) filter['date_published'] = {'range': range};

    if (filter.isNotEmpty) body['filter'] = filter;
    return body;
  }

  static String _sort(SortOrder order) {
    switch (order) {
      case SortOrder.relevance:
        return 'relevance';
      case SortOrder.publicationAsc:
        return 'publication_date:asc';
      case SortOrder.publicationDesc:
        return 'publication_date:desc';
      case SortOrder.filingAsc:
        return 'filing_date:asc';
      case SortOrder.filingDesc:
        return 'filing_date:desc';
    }
  }

  /// Формат API: yyyyMMdd.
  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';
}

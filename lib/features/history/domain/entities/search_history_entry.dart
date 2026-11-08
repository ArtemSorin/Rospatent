import 'package:rospatent/features/patents/domain/entities/search_query.dart';

/// Выполненный поисковый запрос и время, когда он был выполнен.
class SearchHistoryEntry {
  final SearchQuery query;
  final DateTime searchedAt;

  const SearchHistoryEntry({required this.query, required this.searchedAt});

  /// Есть ли в запросе хоть что-то, кроме сортировки.
  bool get hasCriteria =>
      query.text.isNotEmpty ||
      query.patentees.isNotEmpty ||
      query.authors.isNotEmpty ||
      query.publishedFrom != null ||
      query.publishedTo != null;

  /// Одинаковые запросы в истории не дублируются — сравниваем по этому ключу.
  String get key => [
    query.text.trim().toLowerCase(),
    query.patentees.join(';').toLowerCase(),
    query.authors.join(';').toLowerCase(),
    query.sort.name,
    query.publishedFrom?.toIso8601String() ?? '',
    query.publishedTo?.toIso8601String() ?? '',
  ].join('|');
}

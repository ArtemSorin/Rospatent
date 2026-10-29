enum SortOrder {
  relevance,
  publicationAsc,
  publicationDesc,
  filingAsc,
  filingDesc,
}

/// Параметры поиска, не привязанные к конкретному API.
class SearchQuery {
  final String text;
  final List<String> patentees;
  final List<String> authors;
  final SortOrder sort;

  /// Дата публикации не раньше (>=).
  final DateTime? publishedFrom;

  /// Дата публикации не позже (<=).
  final DateTime? publishedTo;

  const SearchQuery({
    this.text = '',
    this.patentees = const [],
    this.authors = const [],
    this.sort = SortOrder.relevance,
    this.publishedFrom,
    this.publishedTo,
  });
}

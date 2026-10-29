import 'patent_summary.dart';

/// Одна страница результатов поиска. Номера страниц начинаются с 0.
class SearchPage {
  final List<PatentSummary> items;
  final int total;
  final int page;
  final int pageSize;

  const SearchPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  int get totalPages => total <= 0 ? 0 : (total + pageSize - 1) ~/ pageSize;
}

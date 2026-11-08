import 'dart:convert';

import 'package:rospatent/features/history/domain/entities/search_history_entry.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

class SearchHistoryEntryModel {
  const SearchHistoryEntryModel._();

  static String encode(SearchHistoryEntry e) => jsonEncode({
    'text': e.query.text,
    'patentees': e.query.patentees,
    'authors': e.query.authors,
    'sort': e.query.sort.name,
    'from': e.query.publishedFrom?.toIso8601String(),
    'to': e.query.publishedTo?.toIso8601String(),
    'at': e.searchedAt.toIso8601String(),
  });

  /// null — если строка повреждена (такие записи просто пропускаются).
  static SearchHistoryEntry? decode(String raw) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final sortName = m['sort'] as String?;
      return SearchHistoryEntry(
        query: SearchQuery(
          text: (m['text'] as String?) ?? '',
          patentees: _strings(m['patentees']),
          authors: _strings(m['authors']),
          sort: SortOrder.values.firstWhere(
            (s) => s.name == sortName,
            orElse: () => SortOrder.relevance,
          ),
          publishedFrom: _date(m['from']),
          publishedTo: _date(m['to']),
        ),
        searchedAt: _date(m['at']) ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<String> _strings(Object? value) =>
      value is List ? value.map((e) => e.toString()).toList() : const [];

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;
}

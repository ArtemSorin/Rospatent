import 'package:rospatent/core/utils/text_utils.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';

import '../entities/patent_stats.dart';

void _inc<K>(Map<K, int> map, K key) => map[key] = (map[key] ?? 0) + 1;

List<MapEntry<String, int>> _top(Map<String, int> map, int n) {
  final list = map.entries.toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  return list.take(n).toList();
}

/// Считает статистику по списку найденных патентов.
class ComputePatentStats {
  const ComputePatentStats();

  // id вида RU2701234C1_20190925: страна, номер, вид документа, дата публикации.
  static final _idRe = RegExp(r'^([A-Za-z]{2})(\d+)([A-Za-z]\d?)_(\d{4})\d{4}$');
  static final _sectionRe = RegExp(r'(?:^|[^A-Za-z0-9])([A-H])\d{2}[A-Z]');

  PatentStats call(List<PatentSummary> patents, int totalFound) {
    final sections = <String, int>{};
    final years = <int, int>{};
    final kinds = <String, int>{};
    final patentees = <String, int>{};
    final inventors = <String, int>{};

    for (final p in patents) {
      final m = _idRe.firstMatch(p.id);
      if (m != null) {
        _inc(kinds, m.group(3)!.toUpperCase());
        final year = int.tryParse(m.group(4)!);
        if (year != null) _inc(years, year);
      }

      final sm = _sectionRe.firstMatch(stripHtml(p.ipc));
      if (sm != null) _inc(sections, sm.group(1)!);

      var owner = stripHtml(p.patentees);
      if (owner.isEmpty) owner = stripHtml(p.applicant);
      if (owner.isNotEmpty) _inc(patentees, owner);

      for (final name in splitNames(stripHtml(p.inventors))) {
        _inc(inventors, name);
      }
    }

    return PatentStats(
      totalFound: totalFound,
      sampleSize: patents.length,
      bySection: sections,
      byYear: years,
      byKind: kinds,
      topPatentees: _top(patentees, 5),
      topInventors: _top(inventors, 5),
      uniquePatentees: patentees.length,
    );
  }
}

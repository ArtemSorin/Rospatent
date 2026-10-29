import 'package:flutter/foundation.dart';
import 'package:rospatent/features/analytics/domain/entities/patent_stats.dart';
import 'package:rospatent/features/analytics/domain/usecases/compute_patent_stats.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';
import 'package:rospatent/features/patents/domain/usecases/search_patents.dart';

/// Сразу считает статистику по текущей странице, затем подгружает
/// расширенную выборку (до [sampleLimit] патентов) и пересчитывает.
class AnalyticsController extends ChangeNotifier {
  AnalyticsController({
    required ComputePatentStats computeStats,
    required SearchPatents searchPatents,
    required this.query,
    required List<PatentSummary> pageItems,
    required int totalFound,
    this.sampleLimit = 100,
  }) : _computeStats = computeStats,
       _searchPatents = searchPatents,
       _pageItems = pageItems,
       _totalFound = totalFound {
    stats = _computeStats(pageItems, totalFound);
  }

  final ComputePatentStats _computeStats;
  final SearchPatents _searchPatents;
  final SearchQuery query;
  final int sampleLimit;
  final List<PatentSummary> _pageItems;
  final int _totalFound;

  late PatentStats stats;
  bool loading = false;
  bool extended = false;

  bool _disposed = false;

  Future<void> start() async {
    if (_totalFound <= _pageItems.length) return;
    loading = true;
    _notify();
    try {
      final result = await _searchPatents(query, page: 0, pageSize: sampleLimit);
      if (result.items.isNotEmpty) {
        stats = _computeStats(result.items, result.total);
        extended = true;
      }
    } catch (_) {
      // остаёмся на данных текущей страницы
    }
    loading = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:rospatent/app/app_scope.dart';
import 'package:rospatent/core/widgets/custom_app_bar.dart';
import 'package:rospatent/features/analytics/domain/entities/patent_stats.dart';
import 'package:rospatent/features/patents/domain/entities/document_kind.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:rospatent/features/patents/domain/entities/search_query.dart';

import '../controllers/analytics_controller.dart';

const _palette = <Color>[
  Color(0xFF2962FF),
  Color(0xFF00BFA5),
  Color(0xFFFFB300),
  Color(0xFF7E57C2),
  Color(0xFFEF5350),
  Color(0xFF66BB6A),
  Color(0xFFFF7043),
  Color(0xFF78909C),
];

/// Аналитика по результатам поиска.
class AnalyzePage extends StatefulWidget {
  final SearchQuery query;
  final List<PatentSummary> pageItems;
  final int totalFound;

  const AnalyzePage({
    super.key,
    required this.query,
    required this.pageItems,
    required this.totalFound,
  });

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  late final AnalyticsController _controller;

  bool get _loading => _controller.loading;
  bool get _extended => _controller.extended;

  @override
  void initState() {
    super.initState();
    final deps = AppScope.of(context);
    _controller = AnalyticsController(
      computeStats: deps.computePatentStats,
      searchPatents: deps.searchPatents,
      query: widget.query,
      pageItems: widget.pageItems,
      totalFound: widget.totalFound,
    )..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- общие элементы ----------

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.15),
        spreadRadius: 1,
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  Widget _card(String title, String? subtitle, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scopeBanner(PatentStats s) {
    final text = _loading
        ? 'Показана текущая страница (${s.sampleSize} из ${s.totalFound}). '
              'Загружаем расширенную выборку…'
        : _extended
        ? 'Анализ первых ${s.sampleSize} из ${s.totalFound} найденных патентов '
              '(в порядке выбранной сортировки)'
        : 'Анализ текущей страницы: ${s.sampleSize} из ${s.totalFound} патентов';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  // ---------- графики ----------

  Widget _yearsCard(PatentStats s) {
    if (s.byYear.isEmpty) return const SizedBox.shrink();
    final years = s.byYear.keys.toList()..sort();
    final maxV = s.byYear.values.reduce(math.max);
    // верхняя граница и шаг оси Y — целые числа, чтобы подписи были «чистыми»
    final maxY = maxV + math.max(1, (maxV * 0.15).ceil());
    final yInterval = math.max(1, (maxY / 4).ceil()).toDouble();
    final step = math.max(1, (years.length / 6).ceil());
    const axisStyle = TextStyle(fontSize: 11, color: Colors.black54);

    return _card(
      'Публикации по годам',
      'Количество патентов по году публикации',
      SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: maxY.toDouble(),
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                      '${years[group.x]}: ${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: yInterval,
                  getTitlesWidget: (v, meta) =>
                      Text(v.toInt().toString(), style: axisStyle),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: 1,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= years.length || i % step != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('${years[i]}', style: axisStyle),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(years.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: s.byYear[years[i]]!.toDouble(),
                    color: _palette[0],
                    width: years.length > 12 ? 8 : 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _sectionsCard(PatentStats s) {
    if (s.bySection.isEmpty) return const SizedBox.shrink();
    final entries = s.bySection.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return _card(
      'Тематика (разделы МПК)',
      'По основной классификации патента',
      Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 52,
                    sectionsSpace: 2,
                    sections: List.generate(entries.length, (i) {
                      final pct = entries[i].value / total * 100;
                      return PieChartSectionData(
                        value: entries[i].value.toDouble(),
                        color: _palette[i % _palette.length],
                        radius: 36,
                        title: pct >= 8 ? entries[i].key : '',
                        titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'патентов',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(entries.length, (i) {
            final e = entries[i];
            final pct = (e.value / total * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _palette[i % _palette.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${e.key} — ${ipcSectionNames[e.key] ?? ''}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  Text(
                    '${e.value} · $pct%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _ranked(List<MapEntry<String, int>> entries, Color color) {
    final maxV = entries.map((e) => e.value).reduce(math.max);
    return Column(
      children: entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.value}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: e.value / maxV,
                  minHeight: 6,
                  color: color,
                  backgroundColor: color.withOpacity(0.12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _kindsCard(PatentStats s) {
    if (s.byKind.isEmpty) return const SizedBox.shrink();
    final entries =
        (s.byKind.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .map((e) => MapEntry('${documentKindLabel(e.key)} (${e.key})', e.value))
            .toList();
    return _card('Типы документов', null, _ranked(entries, _palette[1]));
  }

  Widget _topCard(String title, String? subtitle, List<MapEntry<String, int>> e, Color c) {
    if (e.isEmpty) return const SizedBox.shrink();
    return _card(title, subtitle, _ranked(e, c));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final s = _controller.stats;
        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "Аналитика",
            centerTitle: true,
            leading: IconButton(
              color: Colors.blueAccent,
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Назад',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              if (_loading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _scopeBanner(s),
                    Row(
                      children: [
                        _statTile('Найдено', '${s.totalFound}', Icons.search),
                        const SizedBox(width: 8),
                        _statTile(
                          'Проанализировано',
                          '${s.sampleSize}',
                          Icons.analytics_outlined,
                        ),
                        const SizedBox(width: 8),
                        _statTile(
                          'Правообладателей',
                          '${s.uniquePatentees}',
                          Icons.business_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _yearsCard(s),
                    _sectionsCard(s),
                    _kindsCard(s),
                    _topCard(
                      'Топ правообладателей',
                      'Организации и лица с наибольшим числом патентов',
                      s.topPatentees,
                      _palette[0],
                    ),
                    _topCard(
                      'Топ авторов',
                      null,
                      s.topInventors,
                      _palette[3],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

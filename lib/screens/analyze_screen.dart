import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/custom_app_bar.dart';

class AnalyzePage extends StatelessWidget {
  final Map<String, int> patentsByLanguage;
  final int totalPatents;
  final String topOwner;

  const AnalyzePage({
    super.key,
    required this.patentsByLanguage,
    required this.totalPatents,
    required this.topOwner,
  });

  List<Color> _generateBlueShades(int count) {
    return List.generate(count, (i) {
      final opacity = 1.0 - (i * 0.15);
      return Colors.blueAccent.withOpacity(opacity.clamp(0.4, 1.0));
    });
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> data) {
    final total = data.values.fold(0, (sum, el) => sum + el);
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shades = _generateBlueShades(sorted.length);

    return List.generate(sorted.length, (i) {
      final entry = sorted[i];
      final percent = (entry.value / total) * 100;
      return PieChartSectionData(
        title: '${entry.key}\n${percent.toStringAsFixed(1)}%',
        value: entry.value.toDouble(),
        color: shades[i],
        radius: 70,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _legend(Map<String, int> data) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final shades = _generateBlueShades(sorted.length);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(sorted.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: shades[i],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(sorted[i].key, style: const TextStyle(fontSize: 13)),
          ],
        );
      }),
    );
  }

  Widget _chart(String title, Map<String, int> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(data),
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _legend(data),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _chart("По языкам", patentsByLanguage),
          _statTile("Всего патентов", totalPatents.toString()),
          _statTile("Топ патентообладатель", topOwner),
        ],
      ),
    );
  }
}

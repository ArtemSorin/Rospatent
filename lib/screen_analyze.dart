import 'package:flutter/material.dart';
import 'package:flutter_application1/models/search_page_model.dart';
import 'package:flutter_application1/patent_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  List<GDPData> _chartData = [];
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();

    setState(() {
      getChartData().then((value) {
        _chartData = value;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SfCircularChart(
      title: ChartTitle(text: 'Доля по странам'),
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      tooltipBehavior: _tooltipBehavior,
      series: <CircularSeries>[
        RadialBarSeries<GDPData, String>(
            dataSource: _chartData,
            xValueMapper: (GDPData data, _) => data.continent,
            yValueMapper: (GDPData data, _) => data.gdp,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            enableTooltip: true,
            maximumValue: 10000)
      ],
    )));
  }

  Future<List<GDPData>> getChartData() async {
    var p = SearchPageModel.patents!.params;

    int count = 20;
    List<Patent> pts = [];
    List<GDPData> chartData = [];

    for (int i = 0; i < count; i += p.limit) {
      pts = ((await api.find(p))!.patents);

      Map<String, int> data = {};
      for (Patent pt in pts) {
        pt = await api.getPatent(pt) ?? pt;
        if (data[pt.country] == null) {
          data[pt.country] = 1;
        } else {
          data[pt.country] = (data[pt.country])! + 1;
        }
      }
      for (var key in data.keys) {
        GDPData possible = chartData.firstWhere(
            (element) => element.continent == key,
            orElse: () => GDPData.empty());
        if (possible.continent != null) {
          chartData.remove(possible);
          possible.gdp += data[key] ?? 0;
          chartData.add(possible);
        } else {
          chartData.add(GDPData(key, data[key] ?? 0));
        }
      }
    }
    return chartData;
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);
  GDPData.empty();
  String? continent;
  int gdp = 0;
}

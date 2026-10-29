import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/analytics/domain/entities/patent_stats.dart';
import 'package:rospatent/features/analytics/domain/usecases/compute_patent_stats.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';

void main() {
  const compute = ComputePatentStats();

  group('ipcSectionNames', () {
    test('содержит все 8 разделов A–H', () {
      expect(ipcSectionNames.keys.toList(), ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']);
      expect(ipcSectionNames['G'], 'Физика');
      expect(ipcSectionNames['H'], 'Электричество');
    });
  });

  group('ComputePatentStats', () {
    test('пустой список даёт нулевую статистику', () {
      final s = compute(const [], 0);
      expect(s.totalFound, 0);
      expect(s.sampleSize, 0);
      expect(s.bySection, isEmpty);
      expect(s.byYear, isEmpty);
      expect(s.byKind, isEmpty);
      expect(s.topPatentees, isEmpty);
      expect(s.topInventors, isEmpty);
      expect(s.uniquePatentees, 0);
    });

    test('год и вид документа берутся из id', () {
      final s = compute(const [
        PatentSummary(id: 'RU2701234C1_20190925'),
        PatentSummary(id: 'RU2701235C1_20190101'),
        PatentSummary(id: 'RU9U1_20210101'),
        PatentSummary(id: 'RU3701234c2_20200505'),
      ], 100);
      expect(s.totalFound, 100);
      expect(s.sampleSize, 4);
      expect(s.byYear, {2019: 2, 2021: 1, 2020: 1});
      expect(s.byKind, {'C1': 2, 'U1': 1, 'C2': 1});
    });

    test('id в другом формате игнорируется', () {
      final s = compute(const [PatentSummary(id: 'weird-id'), PatentSummary(id: '')], 2);
      expect(s.byYear, isEmpty);
      expect(s.byKind, isEmpty);
      expect(s.sampleSize, 2);
    });

    test('основной раздел МПК определяется по первой рубрике, подсветка не мешает', () {
      final s = compute(const [
        PatentSummary(id: 'a', ipc: 'G06F 17/30, A61K 1/00'),
        PatentSummary(id: 'b', ipc: '<em>G06N</em> 3/00'),
        PatentSummary(id: 'c', ipc: 'A61K 1/00'),
        PatentSummary(id: 'd', ipc: 'H04L1/00'),
        PatentSummary(id: 'e', ipc: ''),
        PatentSummary(id: 'f', ipc: 'без рубрики'),
        PatentSummary(id: 'g', ipc: 'Z99Z 1/00'),
      ], 7);
      expect(s.bySection, {'G': 2, 'A': 1, 'H': 1});
    });

    test('правообладатели: берётся patentees, иначе applicant', () {
      final s = compute(const [
        PatentSummary(id: 'a', patentees: 'ООО Х', applicant: 'ИП Я'),
        PatentSummary(id: 'b', patentees: 'ООО Х'),
        PatentSummary(id: 'c', applicant: 'ИП Я'),
        PatentSummary(id: 'd'),
        PatentSummary(id: 'e', patentees: '<em>ООО</em> Х'),
      ], 5);
      expect(s.uniquePatentees, 2);
      expect(s.topPatentees.map((e) => '${e.key}:${e.value}').toList(), ['ООО Х:3', 'ИП Я:1']);
    });

    test('авторы разбиваются по запятой и считаются по отдельности', () {
      final s = compute(const [
        PatentSummary(id: 'a', inventors: 'Иванов И.И., Петров П.П.'),
        PatentSummary(id: 'b', inventors: 'Иванов И.И.'),
        PatentSummary(id: 'c', inventors: 'Сидоров С.С.; Иванов И.И.'),
      ], 3);
      expect(s.topInventors.first.key, 'Иванов И.И.');
      expect(s.topInventors.first.value, 3);
      expect(s.topInventors.length, 3);
    });

    test('в топ попадает не больше 5, при равенстве порядок по алфавиту', () {
      final patents = [
        for (final name in ['Е', 'Д', 'Г', 'В', 'Б', 'А', 'Ж'])
          PatentSummary(id: name, patentees: name),
        const PatentSummary(id: 'extra', patentees: 'Ж'),
      ];
      final s = compute(patents, 8);
      expect(s.topPatentees.length, 5);
      expect(s.topPatentees.first.key, 'Ж'); // у неё 2 патента
      expect(s.topPatentees.skip(1).map((e) => e.key).toList(), ['А', 'Б', 'В', 'Г']);
      expect(s.uniquePatentees, 7);
    });
  });
}

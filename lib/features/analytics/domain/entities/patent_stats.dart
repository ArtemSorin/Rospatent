/// Названия разделов МПК.
const ipcSectionNames = <String, String>{
  'A': 'Человеческие потребности',
  'B': 'Технологические процессы, транспорт',
  'C': 'Химия, металлургия',
  'D': 'Текстиль, бумага',
  'E': 'Строительство',
  'F': 'Машиностроение, освещение, отопление',
  'G': 'Физика',
  'H': 'Электричество',
};

/// Агрегированная статистика по выборке патентов.
class PatentStats {
  final int totalFound;
  final int sampleSize;

  /// Основной раздел МПК (A–H) -> количество.
  final Map<String, int> bySection;

  /// Год публикации -> количество.
  final Map<int, int> byYear;

  /// Код вида документа (C1, U1, A ...) -> количество.
  final Map<String, int> byKind;

  final List<MapEntry<String, int>> topPatentees;
  final List<MapEntry<String, int>> topInventors;
  final int uniquePatentees;

  const PatentStats({
    required this.totalFound,
    required this.sampleSize,
    required this.bySection,
    required this.byYear,
    required this.byKind,
    required this.topPatentees,
    required this.topInventors,
    required this.uniquePatentees,
  });
}

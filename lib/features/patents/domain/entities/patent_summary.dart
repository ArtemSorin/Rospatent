/// Краткая информация о патенте из результатов поиска.
/// Текстовые поля могут содержать теги подсветки <em>.
class PatentSummary {
  final String id;
  final String title;
  final String description;
  final String lang;
  final String applicant;
  final String inventors;
  final String patentees;
  final String ipc;
  final String cpc;

  const PatentSummary({
    required this.id,
    this.title = '',
    this.description = '',
    this.lang = '',
    this.applicant = '',
    this.inventors = '',
    this.patentees = '',
    this.ipc = '',
    this.cpc = '',
  });
}

import 'package:rospatent/core/utils/text_utils.dart';

import 'patent_summary.dart';

/// Полная информация о патенте (ответ docs/{id}).
class PatentDetails {
  final String id;
  final String title;
  final String applicationNumber;
  final int? documentNumber;
  final String kind;
  final String guid;
  final String country;
  final DateTime? publicationDate;
  final DateTime? filingDate;
  final List<String> inventors;
  final List<String> patentees;
  final String applicant;
  final String ipc;
  final String cpc;

  /// HTML-фрагменты.
  final String abstractHtml;
  final String claimsHtml;
  final String descriptionHtml;

  const PatentDetails({
    required this.id,
    this.title = '',
    this.applicationNumber = '',
    this.documentNumber,
    this.kind = '',
    this.guid = '',
    this.country = '',
    this.publicationDate,
    this.filingDate,
    this.inventors = const [],
    this.patentees = const [],
    this.applicant = '',
    this.ipc = '',
    this.cpc = '',
    this.abstractHtml = '',
    this.claimsHtml = '',
    this.descriptionHtml = '',
  });

  /// Дополняет пустые поля данными из результатов поиска (там они всегда есть).
  PatentDetails withFallback(PatentSummary? s) {
    if (s == null) return this;
    return PatentDetails(
      id: id,
      title: title.isNotEmpty ? title : stripHtml(s.title),
      applicationNumber: applicationNumber,
      documentNumber: documentNumber,
      kind: kind,
      guid: guid,
      country: country,
      publicationDate: publicationDate,
      filingDate: filingDate,
      inventors: inventors.isNotEmpty ? inventors : splitNames(s.inventors),
      patentees: patentees.isNotEmpty ? patentees : splitNames(s.patentees),
      applicant: applicant.isNotEmpty ? applicant : stripHtml(s.applicant),
      ipc: ipc.isNotEmpty ? ipc : stripHtml(s.ipc),
      cpc: cpc.isNotEmpty ? cpc : stripHtml(s.cpc),
      abstractHtml: abstractHtml,
      claimsHtml: claimsHtml,
      descriptionHtml: descriptionHtml,
    );
  }
}

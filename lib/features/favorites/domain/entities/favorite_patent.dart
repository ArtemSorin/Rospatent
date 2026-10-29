import 'package:rospatent/core/utils/text_utils.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';

/// Патент в избранном. Хранится целиком, чтобы список работал без сети.
class FavoritePatent {
  final String id;
  final String title;
  final String description;
  final String applicationNumber;
  final int? documentNumber;
  final String kind;
  final String guid;
  final String country;
  final String ipc;
  final String cpc;
  final String inventors;
  final String patentees;
  final String applicant;
  final DateTime? publicationDate;
  final DateTime? filingDate;
  final DateTime addedAt;

  const FavoritePatent({
    required this.id,
    required this.title,
    this.description = '',
    this.applicationNumber = '',
    this.documentNumber,
    this.kind = '',
    this.guid = '',
    this.country = '',
    this.ipc = '',
    this.cpc = '',
    this.inventors = '',
    this.patentees = '',
    this.applicant = '',
    this.publicationDate,
    this.filingDate,
    required this.addedAt,
  });

  factory FavoritePatent.fromDetails(PatentDetails d, {DateTime? now}) {
    final source = d.descriptionHtml.isNotEmpty
        ? d.descriptionHtml
        : d.abstractHtml;
    return FavoritePatent(
      id: d.id,
      title: stripHtml(d.title),
      description: truncate(stripHtml(source), 400),
      applicationNumber: d.applicationNumber,
      documentNumber: d.documentNumber,
      kind: d.kind,
      guid: d.guid,
      country: d.country,
      ipc: stripHtml(d.ipc),
      cpc: stripHtml(d.cpc),
      inventors: d.inventors.join(', '),
      patentees: d.patentees.join(', '),
      applicant: stripHtml(d.applicant),
      publicationDate: d.publicationDate,
      filingDate: d.filingDate,
      addedAt: now ?? DateTime.now(),
    );
  }

  /// Данные для открытия экрана патента: недостающее добирается из API.
  PatentSummary toSummary() => PatentSummary(
    id: id,
    title: title,
    description: description,
    applicant: applicant,
    inventors: inventors,
    patentees: patentees,
    ipc: ipc,
    cpc: cpc,
  );
}

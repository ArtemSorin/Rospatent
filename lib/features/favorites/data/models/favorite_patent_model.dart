import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';

/// Преобразование FavoritePatent <-> строка таблицы favorites.
class FavoritePatentModel {
  const FavoritePatentModel._(); // coverage:ignore-line

  static Map<String, Object?> toMap(FavoritePatent p) => {
    'id': p.id,
    'title': p.title,
    'description': p.description,
    'application_number': p.applicationNumber,
    'document_number': p.documentNumber ?? -1,
    'kind': p.kind,
    'guid': p.guid,
    'country': p.country,
    'lang': '',
    'ipc': p.ipc,
    'cpc': p.cpc,
    'inventor': p.inventors,
    'patentee': p.patentees,
    'applicant': p.applicant,
    'publication_date': p.publicationDate?.toIso8601String(),
    'filing_date': p.filingDate?.toIso8601String(),
    'added_at': p.addedAt.millisecondsSinceEpoch,
  };

  static FavoritePatent fromMap(Map<String, Object?> m) {
    String text(String key) => (m[key] as String?) ?? '';
    DateTime? date(Object? v) => v == null ? null : DateTime.tryParse('$v');
    final docNumber = m['document_number'] as int?;
    return FavoritePatent(
      id: m['id'] as String,
      title: text('title'),
      description: text('description'),
      applicationNumber: text('application_number'),
      documentNumber: (docNumber == null || docNumber < 0) ? null : docNumber,
      kind: text('kind'),
      guid: text('guid'),
      country: text('country'),
      ipc: text('ipc'),
      cpc: text('cpc'),
      inventors: text('inventor'),
      patentees: text('patentee'),
      applicant: text('applicant'),
      publicationDate: date(m['publication_date']),
      filingDate: date(m['filing_date']),
      addedAt: DateTime.fromMillisecondsSinceEpoch((m['added_at'] as int?) ?? 0),
    );
  }
}

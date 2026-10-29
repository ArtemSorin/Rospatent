import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';

import 'json_readers.dart';

/// Разбор одного элемента hits из ответа /search.
class PatentSummaryModel {
  const PatentSummaryModel._(); // coverage:ignore-line

  static PatentSummary fromHit(Map<String, dynamic> hit) {
    final snippet = asMap(hit['snippet']);
    final classification = asMap(snippet['classification']);
    return PatentSummary(
      id: asText(hit['id']),
      title: asText(snippet['title']),
      description: asText(snippet['description']),
      lang: asText(snippet['lang']),
      applicant: asText(snippet['applicant']),
      inventors: asText(snippet['inventor']),
      patentees: asText(snippet['patentee']),
      ipc: classificationText(classification['ipc']),
      cpc: classificationText(classification['cpc']),
    );
  }
}

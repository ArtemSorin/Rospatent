import 'dart:developer' as developer;

import 'package:rospatent/features/patents/domain/entities/patent_details.dart';

import 'json_readers.dart';

/// Разбор ответа /docs/{id}. Читает данные устойчиво к разным формам JSON.
class PatentDetailsModel {
  const PatentDetailsModel._(); // coverage:ignore-line

  static const _lang = 'ru';

  static PatentDetails fromJson(
    Map<String, dynamic> data, {
    required String fallbackId,
  }) {
    final common = asMap(data['common']);
    final application = asMap(common['application']);
    final classification = asMap(common['classification']);
    final blocks = _biblioBlocks(data['biblio']);

    final abstractHtml = localizedText(data['abstract'], lang: _lang);
    final claimsHtml = localizedText(data['claims'], lang: _lang);
    final descriptionHtml = localizedText(data['description'], lang: _lang);

    if (abstractHtml.isEmpty && claimsHtml.isEmpty && descriptionHtml.isEmpty) {
      developer.log(
        'Реферат, формула и описание пустые. Ключи ответа: ${data.keys.toList()}; '
        'abstract=${data['abstract'].runtimeType}, '
        'claims=${data['claims'].runtimeType}, '
        'description=${data['description'].runtimeType}',
        name: 'PatentDetailsModel',
      );
    }

    return PatentDetails(
      id: asText(data['id']).isEmpty ? fallbackId : asText(data['id']),
      title: _firstText(blocks, const ['title']),
      applicationNumber: asText(application['number']),
      documentNumber: int.tryParse(asText(common['document_number'])),
      kind: asText(common['kind']),
      guid: asText(common['guid']),
      country: asText(common['publishing_office']),
      publicationDate: readDate(common['publication_date']),
      filingDate: readDate(application['filing_date']),
      inventors: _firstNames(blocks, const [
        'inventor',
        'inventors',
        'author',
        'authors',
      ]),
      patentees: _firstNames(blocks, const [
        'patentee',
        'patentees',
        'patent_holder',
        'patent_holders',
      ]),
      applicant: _firstNames(blocks, const ['applicant', 'applicants']).join(', '),
      ipc: classificationText(classification['ipc']),
      cpc: classificationText(classification['cpc']),
      abstractHtml: abstractHtml,
      claimsHtml: claimsHtml,
      descriptionHtml: descriptionHtml,
    );
  }

  /// Блоки biblio по языкам: русский первым, затем остальные.
  static List<Map<String, dynamic>> _biblioBlocks(dynamic biblio) {
    if (biblio is! Map) return const [];
    final map = Map<String, dynamic>.from(biblio);
    // «плоский» biblio без разбивки по языкам
    if (map.containsKey('title') || map.containsKey('inventor')) return [map];

    final blocks = <Map<String, dynamic>>[];
    final ru = map[_lang];
    if (ru is Map) blocks.add(asMap(ru));
    for (final entry in map.entries) {
      if (entry.key != _lang && entry.value is Map) {
        blocks.add(asMap(entry.value));
      }
    }
    return blocks;
  }

  static String _firstText(List<Map<String, dynamic>> blocks, List<String> keys) {
    for (final block in blocks) {
      for (final key in keys) {
        final text = localizedText(block[key], lang: _lang);
        if (text.trim().isNotEmpty) return text;
      }
    }
    return '';
  }

  static List<String> _firstNames(
    List<Map<String, dynamic>> blocks,
    List<String> keys,
  ) {
    for (final block in blocks) {
      for (final key in keys) {
        final names = nameList(block[key], lang: _lang);
        if (names.isNotEmpty) return names;
      }
    }
    return const [];
  }
}

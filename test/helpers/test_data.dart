import 'package:rospatent/features/favorites/domain/entities/favorite_patent.dart';
import 'package:rospatent/features/patents/domain/entities/patent_details.dart';
import 'package:rospatent/features/patents/domain/entities/patent_summary.dart';
import 'package:rospatent/features/patents/domain/entities/search_page.dart';

PatentSummary makeSummary({
  String id = 'RU2701234C1_20190925',
  String title = 'Способ <em>обработки</em> данных',
  String description = 'Описание <em>способа</em> обработки',
  String lang = 'ru',
  String applicant = 'ООО Заявитель',
  String inventors = 'Иванов И.И., Петров П.П.',
  String patentees = 'ООО Ромашка',
  String ipc = 'G06F 17/30',
  String cpc = 'G06N 3/00',
}) => PatentSummary(
  id: id,
  title: title,
  description: description,
  lang: lang,
  applicant: applicant,
  inventors: inventors,
  patentees: patentees,
  ipc: ipc,
  cpc: cpc,
);

PatentDetails makeDetails({
  String id = 'RU2701234C1_20190925',
  String title = 'Способ обработки данных',
  String applicationNumber = '2018111222',
  int? documentNumber = 2701234,
  String kind = 'C1',
  String guid = 'guid-1',
  String country = 'RU',
  DateTime? publicationDate,
  DateTime? filingDate,
  List<String> inventors = const ['Иванов И.И.', 'Петров П.П.'],
  List<String> patentees = const ['ООО Ромашка'],
  String applicant = 'ООО Заявитель',
  String ipc = 'G06F 17/30',
  String cpc = 'G06N 3/00',
  String abstractHtml = '<p>Реферат патента</p>',
  String claimsHtml = '<p>1. Формула патента</p>',
  String descriptionHtml = '<p>Описание патента</p>',
}) => PatentDetails(
  id: id,
  title: title,
  applicationNumber: applicationNumber,
  documentNumber: documentNumber,
  kind: kind,
  guid: guid,
  country: country,
  publicationDate: publicationDate ?? DateTime(2019, 9, 25),
  filingDate: filingDate ?? DateTime(2018, 3, 28),
  inventors: inventors,
  patentees: patentees,
  applicant: applicant,
  ipc: ipc,
  cpc: cpc,
  abstractHtml: abstractHtml,
  claimsHtml: claimsHtml,
  descriptionHtml: descriptionHtml,
);

/// Страница результатов: элементы нумеруются сквозно (Патент №1, №2 ...).
SearchPage makePage({
  int total = 25,
  int page = 0,
  int pageSize = 10,
  int? count,
}) {
  final start = page * pageSize;
  final n = count ?? (total - start).clamp(0, pageSize).toInt();
  return SearchPage(
    items: List.generate(n, (i) {
      final number = start + i + 1;
      return makeSummary(
        id: 'RU${1000 + number}C1_2019${(number % 12 + 1).toString().padLeft(2, '0')}01',
        title: 'Патент №$number.',
        description: 'Описание выдачи №$number.',
      );
    }),
    total: total,
    page: page,
    pageSize: pageSize,
  );
}

FavoritePatent makeFavorite({
  String id = 'RU2701234C1_20190925',
  String title = 'Способ обработки данных',
  String description = 'Краткое описание патента',
  String applicationNumber = '2018111222',
  int? documentNumber = 2701234,
  String kind = 'C1',
  String guid = 'guid-1',
  String country = 'RU',
  String ipc = 'G06F 17/30',
  String cpc = 'G06N 3/00',
  String inventors = 'Иванов И.И., Петров П.П.',
  String patentees = 'ООО Ромашка',
  String applicant = 'ООО Заявитель',
  DateTime? publicationDate,
  DateTime? filingDate,
  DateTime? addedAt,
}) => FavoritePatent(
  id: id,
  title: title,
  description: description,
  applicationNumber: applicationNumber,
  documentNumber: documentNumber,
  kind: kind,
  guid: guid,
  country: country,
  ipc: ipc,
  cpc: cpc,
  inventors: inventors,
  patentees: patentees,
  applicant: applicant,
  publicationDate: publicationDate ?? DateTime(2019, 9, 25),
  filingDate: filingDate ?? DateTime(2018, 3, 28),
  addedAt: addedAt ?? DateTime(2024, 1, 1),
);

/// Ответ /docs/{id} в «каноничной» форме (язык -> значение).
Map<String, dynamic> docJson() => {
  'id': 'RU2701234C1_20190925',
  'common': {
    'publishing_office': 'RU',
    'document_number': '2701234',
    'kind': 'C1',
    'guid': 'guid-1',
    'publication_date': '2019.09.25',
    'application': {'number': '2018111222', 'filing_date': '2018.03.28'},
    'classification': {
      'ipc': [
        {'symbol': 'G06F 17/30'},
      ],
      'cpc': ['G06N 3/00'],
    },
  },
  'biblio': {
    'ru': {
      'title': 'Способ',
      'inventor': [
        {'name': 'Иванов И.И.'},
        {'name': 'Петров П.П.'},
      ],
      'patentee': [
        {'name': 'ООО Ромашка'},
      ],
      'applicant': ['ООО Заявитель'],
    },
    'en': {'title': 'Method'},
  },
  'abstract': {'ru': '<p>Реферат</p>', 'en': 'Abstract'},
  'claims': {'ru': '<p>1. Способ</p>'},
  'description': {'ru': '<p>Описание</p>'},
};

/// Ответ /search с двумя находками.
Map<String, dynamic> searchJson({int total = 2}) => {
  'total': total,
  'hits': [
    {
      'id': 'RU1C1_20200101',
      'snippet': {
        'title': '<em>Т</em>1',
        'description': 'описание 1',
        'lang': 'ru',
        'applicant': 'Заявитель 1',
        'inventor': 'Иванов И.И.',
        'patentee': 'ООО Один',
        'classification': {
          'ipc': 'G06F 1/00',
          'cpc': ['H04L 1/00', 'H04L 2/00'],
        },
      },
    },
    {'id': 'RU2U1_20210202', 'snippet': {'title': 'Т2'}},
  ],
};

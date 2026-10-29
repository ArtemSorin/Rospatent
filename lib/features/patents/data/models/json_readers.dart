/// Устойчивые к формату ответа функции чтения JSON.
/// Поля Роспатента (реферат, формула, описание, авторы...) могут приходить как
/// строка, как словарь «язык -> значение» или как список — читаем все варианты.

/// Код языка: «ru», «en» или с регионом («ru-RU»).
final _langCode = RegExp(r'^[A-Za-z]{2}(?:[-_][A-Za-z]{2})?$');

bool _isLangMap(Map node) =>
    node.isNotEmpty && node.keys.every((k) => k is String && _langCode.hasMatch(k));

/// Любое скалярное значение или список скаляров -> строка через запятую.
String asText(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is num || v is bool) return '$v';
  if (v is List) {
    return v.map(asText).where((e) => e.trim().isNotEmpty).join(', ');
  }
  return '';
}

/// Текст на предпочтительном языке: строка, {ru: ..., en: ...},
/// [{lang: ru, text: ...}] или объект с полем text/value/content/html.
String localizedText(dynamic node, {String lang = 'ru'}) {
  if (node == null) return '';
  if (node is String) return node;
  if (node is num || node is bool) return '$node';

  if (node is Map) {
    if (_isLangMap(node)) {
      final preferred = localizedText(node[lang], lang: lang);
      if (preferred.trim().isNotEmpty) return preferred;
      for (final value in node.values) {
        final text = localizedText(value, lang: lang);
        if (text.trim().isNotEmpty) return text;
      }
      return '';
    }
    for (final key in const ['text', 'value', 'content', 'html']) {
      if (node.containsKey(key)) {
        final text = localizedText(node[key], lang: lang);
        if (text.trim().isNotEmpty) return text;
      }
    }
    return '';
  }

  if (node is List) {
    final tagged = node.whereType<Map>().where(
      (m) => (m['lang'] ?? m['language']) != null,
    );
    if (tagged.isNotEmpty) {
      final wanted = tagged.where((m) => (m['lang'] ?? m['language']) == lang);
      final group = wanted.isNotEmpty
          ? wanted
          : tagged.where(
              (m) =>
                  (m['lang'] ?? m['language']) ==
                  (tagged.first['lang'] ?? tagged.first['language']),
            );
      return group
          .map((m) => localizedText(m, lang: lang))
          .where((e) => e.trim().isNotEmpty)
          .join('\n');
    }
    return node
        .map((e) => localizedText(e, lang: lang))
        .where((e) => e.trim().isNotEmpty)
        .join('\n');
  }
  return '';
}

/// Список имён: ["А", "Б"], [{name: "А"}], {ru: [...]}, "А".
List<String> nameList(dynamic node, {String lang = 'ru'}) {
  if (node == null) return const [];
  if (node is String) {
    final s = node.trim();
    return s.isEmpty ? const [] : [s];
  }
  if (node is Map) {
    if (_isLangMap(node)) {
      final preferred = nameList(node[lang], lang: lang);
      if (preferred.isNotEmpty) return preferred;
      for (final value in node.values) {
        final names = nameList(value, lang: lang);
        if (names.isNotEmpty) return names;
      }
      return const [];
    }
    final name = _personName(node);
    return name.isEmpty ? const [] : [name];
  }
  if (node is List) {
    final result = <String>[];
    for (final item in node) {
      if (item is String) {
        if (item.trim().isNotEmpty) result.add(item.trim());
      } else if (item is Map) {
        final name = _personName(item);
        if (name.isNotEmpty) result.add(name);
      }
    }
    return result;
  }
  return const [];
}

String _personName(Map m) {
  for (final key in const ['name', 'full_name', 'fio', 'value', 'text']) {
    final v = m[key];
    if (v is String && v.trim().isNotEmpty) return v.trim();
  }
  return '';
}

/// Классификация (МПК/СПК): строка, список строк или список объектов.
String classificationText(dynamic node) {
  if (node == null) return '';
  if (node is String) return node;
  if (node is List) {
    return node
        .map(classificationText)
        .where((e) => e.trim().isNotEmpty)
        .join(', ');
  }
  if (node is Map) {
    for (final key in const ['symbol', 'classification', 'code', 'name', 'value']) {
      final v = node[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
  }
  return '';
}

DateTime? readDate(dynamic v) {
  final s = asText(v).trim().replaceAll('.', '-');
  if (s.isEmpty) return null;
  final d = DateTime.tryParse(s);
  return (d == null || d.year < 1900) ? null : d;
}

Map<String, dynamic> asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

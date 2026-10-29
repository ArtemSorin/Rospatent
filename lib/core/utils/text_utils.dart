/// Убирает HTML-теги (в т.ч. <em> из подсветки поиска) и HTML-сущности.
String stripHtml(String? input) {
  if (input == null || input.isEmpty) return '';
  return input
      // блочные теги превращаем в пробел, чтобы слова не склеивались
      .replaceAll(RegExp(r'</?(p|br|div|li|ul|ol|tr|td|table|h\d)[^>]*>'), ' ')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&amp;', '&')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Обрезает текст до [max] символов по границе слова и добавляет «…».
String truncate(String text, int max) {
  if (text.length <= max) return text;
  var cut = text.substring(0, max);
  final lastSpace = cut.lastIndexOf(' ');
  if (lastSpace > max * 0.6) cut = cut.substring(0, lastSpace);
  return '${cut.trimRight()}…';
}

/// «Иванов И.И., Петров П.П.» -> [«Иванов И.И.», «Петров П.П.»]
List<String> splitNames(String? input) {
  if (input == null) return const [];
  return input
      .split(RegExp(r'[;,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

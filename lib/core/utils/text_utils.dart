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

/// 1234567 -> «1 234 567» (с неразрывными пробелами).
String formatInt(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('\u00A0');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

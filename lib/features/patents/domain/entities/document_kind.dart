/// Человекочитаемое название вида документа по коду (A, C1, U1, S1 ...).
String documentKindLabel(String kind) {
  if (kind.isEmpty) return 'Документ';
  switch (kind[0].toUpperCase()) {
    case 'A':
      return 'Заявка на изобретение';
    case 'C':
      return 'Патент на изобретение';
    case 'U':
      return 'Полезная модель';
    case 'S':
      return 'Промышленный образец';
    default:
      return 'Документ $kind';
  }
}

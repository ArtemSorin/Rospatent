import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/utils/text_utils.dart';

void main() {
  group('stripHtml', () {
    test('null и пустая строка дают пустую строку', () {
      expect(stripHtml(null), '');
      expect(stripHtml(''), '');
    });

    test('обычный текст не меняется', () {
      expect(stripHtml('просто текст'), 'просто текст');
    });

    test('убирает теги подсветки без лишних пробелов', () {
      expect(stripHtml('<em>слово</em>, ещё'), 'слово, ещё');
      expect(stripHtml('Способ <em>обработки</em> данных'), 'Способ обработки данных');
    });

    test('блочные теги разделяют слова пробелом', () {
      expect(stripHtml('<p>первый</p><p>второй</p>'), 'первый второй');
      expect(stripHtml('a<br/>b'), 'a b');
      expect(stripHtml('<ul><li>один</li><li>два</li></ul>'), 'один два');
      expect(stripHtml('<h2>Заголовок</h2>текст'), 'Заголовок текст');
    });

    test('теги с атрибутами тоже удаляются', () {
      expect(stripHtml('<a href="x" class="y">ссылка</a>'), 'ссылка');
      expect(stripHtml('<div class="c">блок</div>'), 'блок');
    });

    test('декодирует HTML-сущности', () {
      expect(stripHtml('a&nbsp;b'), 'a b');
      expect(stripHtml('&lt;x&gt;'), '<x>');
      expect(stripHtml('&quot;цитата&quot;'), '"цитата"');
      expect(stripHtml('Tom &amp; Jerry'), 'Tom & Jerry');
    });

    test('двойное экранирование раскрывается только один раз', () {
      expect(stripHtml('&amp;lt;'), '&lt;');
    });

    test('схлопывает пробелы и переводы строк', () {
      expect(stripHtml('  много \n\n  пробелов\t тут  '), 'много пробелов тут');
    });
  });

  group('truncate', () {
    test('короткий текст возвращается как есть', () {
      expect(truncate('коротко', 20), 'коротко');
    });

    test('текст ровно максимальной длины не обрезается', () {
      expect(truncate('12345', 5), '12345');
    });

    test('режет по границе слова', () {
      expect(truncate('hello world foo', 12), 'hello world…');
    });

    test('без подходящего пробела режет жёстко', () {
      expect(truncate('abcdefghijkl', 5), 'abcde…');
    });

    test('слишком ранний пробел не используется для обрезки', () {
      expect(truncate('ab cdefghijklmnop', 10), 'ab cdefghi…');
    });

    test('убирает хвостовые пробелы перед многоточием', () {
      expect(truncate('hello   world', 8), 'hello…');
    });
  });

  group('splitNames', () {
    test('null и пустая строка дают пустой список', () {
      expect(splitNames(null), isEmpty);
      expect(splitNames(''), isEmpty);
      expect(splitNames('   '), isEmpty);
    });

    test('разбивает по запятой и точке с запятой', () {
      expect(splitNames('Иванов И.И., Петров П.П.; Сидоров С.С.'),
          ['Иванов И.И.', 'Петров П.П.', 'Сидоров С.С.']);
    });

    test('обрезает пробелы и пропускает пустые элементы', () {
      expect(splitNames(' А ,, Б ; ; '), ['А', 'Б']);
    });

    test('одно имя остаётся одним элементом', () {
      expect(splitNames('ООО Ромашка'), ['ООО Ромашка']);
    });
  });
}

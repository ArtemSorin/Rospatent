import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/features/patents/data/models/json_readers.dart';

void main() {
  group('asText', () {
    test('null -> пустая строка', () => expect(asText(null), ''));
    test('строка как есть', () => expect(asText('abc'), 'abc'));
    test('числа и bool приводятся к строке', () {
      expect(asText(42), '42');
      expect(asText(1.5), '1.5');
      expect(asText(true), 'true');
    });
    test('список склеивается через запятую, пустые пропускаются', () {
      expect(asText(['a', '', '  ', 'b', null, 3]), 'a, b, 3');
    });
    test('словарь не поддерживается -> пустая строка', () {
      expect(asText({'a': 1}), '');
    });
  });

  group('localizedText', () {
    test('null и неподдерживаемые типы', () {
      expect(localizedText(null), '');
      expect(localizedText(DateTime(2020)), '');
    });
    test('строка и скаляры', () {
      expect(localizedText('текст'), 'текст');
      expect(localizedText(5), '5');
      expect(localizedText(false), 'false');
    });

    group('словарь языков', () {
      test('берёт предпочтительный язык', () {
        expect(localizedText({'ru': 'русский', 'en': 'english'}), 'русский');
      });
      test('если нужного языка нет — первый непустой', () {
        expect(localizedText({'ru': '  ', 'en': 'english'}), 'english');
        expect(localizedText({'de': 'deutsch'}), 'deutsch');
      });
      test('все значения пустые -> пустая строка', () {
        expect(localizedText({'ru': '', 'en': ''}), '');
      });
      test('другой предпочтительный язык', () {
        expect(localizedText({'ru': 'ру', 'en': 'en'}, lang: 'en'), 'en');
      });
      test('ключ с регионом («ru-RU») тоже считается языком', () {
        expect(localizedText({'ru-RU': 'текст'}), 'текст');
      });
      test('трёхбуквенный ключ не считается языком', () {
        expect(localizedText({'url': 'http://x'}), '');
      });
      test('значение может быть объектом', () {
        expect(localizedText({'ru': {'text': '<p>x</p>'}}), '<p>x</p>');
      });
    });

    group('объект с полем-текстом', () {
      test('text / value / content / html', () {
        expect(localizedText({'text': 'a'}), 'a');
        expect(localizedText({'value': 'b'}), 'b');
        expect(localizedText({'content': 'c'}), 'c');
        expect(localizedText({'html': 'd'}), 'd');
      });
      test('пропускает пустое поле и берёт следующее', () {
        expect(localizedText({'text': '', 'value': 'v'}), 'v');
      });
      test('без известных ключей -> пустая строка', () {
        expect(localizedText({'foo': 'bar'}), '');
        expect(localizedText({'text': ''}), '');
      });
    });

    group('список', () {
      test('элементы с lang: берутся нужного языка', () {
        final node = [
          {'lang': 'en', 'text': 'EN'},
          {'lang': 'ru', 'text': 'РУ'},
        ];
        expect(localizedText(node), 'РУ');
      });
      test('поддерживается ключ language', () {
        expect(localizedText([{'language': 'ru', 'text': 'x'}]), 'x');
      });
      test('несколько фрагментов одного языка склеиваются переводом строки', () {
        final node = [
          {'lang': 'ru', 'text': 'а'},
          {'lang': 'ru', 'text': 'б'},
          {'lang': 'en', 'text': 'c'},
        ];
        expect(localizedText(node), 'а\nб');
      });
      test('нет нужного языка — берётся язык первого элемента', () {
        final node = [
          {'lang': 'en', 'text': 'e1'},
          {'lang': 'de', 'text': 'd1'},
          {'lang': 'en', 'text': 'e2'},
        ];
        expect(localizedText(node), 'e1\ne2');
      });
      test('пустые тексты в размеченном списке пропускаются', () {
        final node = [
          {'lang': 'ru', 'text': ''},
          {'lang': 'ru', 'text': 'x'},
        ];
        expect(localizedText(node), 'x');
      });
      test('список строк склеивается, пустые пропускаются', () {
        expect(localizedText(['а', '', 'б']), 'а\nб');
      });
      test('пустой список', () => expect(localizedText([]), ''));
    });
  });

  group('nameList', () {
    test('null и неподдерживаемые типы', () {
      expect(nameList(null), isEmpty);
      expect(nameList(42), isEmpty);
    });
    test('строка', () {
      expect(nameList('  Иванов  '), ['Иванов']);
      expect(nameList('   '), isEmpty);
    });
    test('список строк (пустые пропускаются)', () {
      expect(nameList(['А', ' ', 'Б']), ['А', 'Б']);
    });
    test('список объектов с разными ключами имени', () {
      expect(nameList([
        {'name': 'А'}, {'full_name': 'Б'}, {'fio': 'В'}, {'value': 'Г'}, {'text': 'Д'},
      ]), ['А', 'Б', 'В', 'Г', 'Д']);
    });
    test('объекты без имени и посторонние элементы пропускаются', () {
      expect(nameList([{'country': 'RU'}, 5, {'name': 'А'}, {'name': '  '}]), ['А']);
    });
    test('один объект-человек', () {
      expect(nameList({'name': 'А'}), ['А']);
      expect(nameList({'country': 'RU'}), isEmpty);
    });
    group('словарь языков', () {
      test('предпочтительный язык', () {
        expect(nameList({'ru': ['А'], 'en': ['A']}), ['А']);
      });
      test('если для языка пусто — первый непустой', () {
        expect(nameList({'ru': [], 'en': ['A']}), ['A']);
      });
      test('везде пусто', () {
        expect(nameList({'ru': [], 'en': []}), isEmpty);
      });
    });
  });

  group('classificationText', () {
    test('null', () => expect(classificationText(null), ''));
    test('строка', () => expect(classificationText('G06F 1/00'), 'G06F 1/00'));
    test('список строк', () {
      expect(classificationText(['G06F 1/00', 'H04L 1/00']), 'G06F 1/00, H04L 1/00');
    });
    test('список объектов, пустые пропускаются', () {
      expect(classificationText([{'symbol': 'A'}, {'code': ''}, {'name': 'B'}]), 'A, B');
    });
    test('приоритет ключей symbol > classification > code > name > value', () {
      expect(classificationText({'value': 'v', 'name': 'n', 'code': 'c', 'classification': 'k', 'symbol': 's'}), 's');
      expect(classificationText({'value': 'v', 'name': 'n', 'code': 'c', 'classification': 'k'}), 'k');
      expect(classificationText({'value': 'v', 'name': 'n', 'code': 'c'}), 'c');
      expect(classificationText({'value': 'v', 'name': 'n'}), 'n');
      expect(classificationText({'value': 'v'}), 'v');
    });
    test('объект без известных ключей и неподдерживаемый тип', () {
      expect(classificationText({'foo': 'x'}), '');
      expect(classificationText(7), '');
    });
  });

  group('readDate', () {
    test('null и пустая строка', () {
      expect(readDate(null), isNull);
      expect(readDate(''), isNull);
    });
    test('формат с точками', () => expect(readDate('2019.09.25'), DateTime(2019, 9, 25)));
    test('формат с дефисами', () => expect(readDate('2019-09-25'), DateTime(2019, 9, 25)));
    test('компактный формат', () => expect(readDate('20190925'), DateTime(2019, 9, 25)));
    test('число приводится к строке', () => expect(readDate(20190925), DateTime(2019, 9, 25)));
    test('мусор -> null', () => expect(readDate('не дата'), isNull));
    test('слишком старый год -> null', () => expect(readDate('1800-01-01'), isNull));
  });

  group('asMap', () {
    test('копирует словарь', () {
      final src = {'a': 1};
      final copy = asMap(src);
      expect(copy, {'a': 1});
      expect(identical(copy, src), isFalse);
    });
    test('не словарь -> пустой словарь', () {
      expect(asMap(null), isEmpty);
      expect(asMap('x'), isEmpty);
      expect(asMap([1]), isEmpty);
    });
  });
}

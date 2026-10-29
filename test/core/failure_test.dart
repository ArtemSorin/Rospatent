import 'package:flutter_test/flutter_test.dart';
import 'package:rospatent/core/error/failure.dart';

void main() {
  group('Failure', () {
    test('хранит сообщение и возвращает его из toString', () {
      const failure = Failure('что-то пошло не так');
      expect(failure.message, 'что-то пошло не так');
      expect(failure.toString(), 'что-то пошло не так');
    });

    test('является Exception', () {
      expect(const Failure('x'), isA<Exception>());
    });

    test('можно выбросить и поймать как Failure', () async {
      await expectLater(() => throw const Failure('boom'), throwsA(isA<Failure>()));
    });
  });

  group('NetworkFailure', () {
    test('сообщение по умолчанию', () {
      expect(const NetworkFailure().message, 'Нет соединения с сервером');
    });

    test('принимает своё сообщение', () {
      const f = NetworkFailure('Таймаут');
      expect(f.message, 'Таймаут');
      expect(f, isA<Failure>());
    });
  });

  group('ServerFailure', () {
    test('хранит код ответа', () {
      const f = ServerFailure('Ошибка сервера (500)', statusCode: 500);
      expect(f.message, 'Ошибка сервера (500)');
      expect(f.statusCode, 500);
      expect(f, isA<Failure>());
    });

    test('код ответа необязателен', () {
      expect(const ServerFailure('x').statusCode, isNull);
    });
  });

  group('ParsingFailure', () {
    test('сообщение по умолчанию', () {
      expect(const ParsingFailure().message, 'Не удалось разобрать ответ сервера');
    });

    test('принимает своё сообщение', () {
      expect(const ParsingFailure('битый json').message, 'битый json');
    });
  });

  group('StorageFailure', () {
    test('сообщение по умолчанию', () {
      expect(const StorageFailure().message, 'Ошибка локального хранилища');
    });

    test('принимает своё сообщение', () {
      expect(const StorageFailure('диск полон').message, 'диск полон');
      expect(const StorageFailure(), isA<Failure>());
    });
  });
}

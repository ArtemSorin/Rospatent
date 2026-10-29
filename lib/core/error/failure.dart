/// Базовый тип ошибок приложения. Слой data превращает технические
/// исключения (сеть, парсинг, БД) в [Failure], а presentation показывает
/// [message] пользователю.
class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет соединения с сервером']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Не удалось разобрать ответ сервера']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Ошибка локального хранилища']);
}

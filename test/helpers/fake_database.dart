import 'package:sqflite/sqflite.dart';

/// Поддельная БД sqflite в памяти. Реализована через noSuchMethod, чтобы не
/// зависеть от точных сигнатур Database: поддерживает execute, query, insert, delete
/// ровно в тех формах, что использует FavoritesLocalDataSource.
class FakeDatabase implements Database {
  final List<String> executed = [];
  final Map<String, Map<String, Object?>> rows = {};

  /// Если задано — каждая операция завершается этой ошибкой.
  Object? failWith;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    final args = invocation.positionalArguments;
    final named = invocation.namedArguments;

    if (failWith != null) return Future<void>.error(failWith!);

    if (name == #execute) {
      executed.add(args[0] as String);
      return Future<void>.value();
    }
    if (name == #insert) {
      final row = Map<String, Object?>.from(args[1] as Map);
      rows[row['id'] as String] = row;
      return Future<int>.value(1);
    }
    if (name == #delete) {
      final id = (named[#whereArgs] as List).first as String;
      return Future<int>.value(rows.remove(id) == null ? 0 : 1);
    }
    if (name == #query) {
      var result = rows.values.map((r) => Map<String, Object?>.from(r)).toList();
      final where = named[#where] as String?;
      if (where == 'id = ?') {
        final id = (named[#whereArgs] as List).first;
        result = result.where((r) => r['id'] == id).toList();
      }
      if (named[#orderBy] == 'added_at DESC') {
        result.sort((a, b) => (b['added_at'] as int).compareTo(a['added_at'] as int));
      }
      final limit = named[#limit] as int?;
      if (limit != null && result.length > limit) result = result.sublist(0, limit);
      return Future<List<Map<String, Object?>>>.value(result);
    }
    return super.noSuchMethod(invocation);
  }
}

/// Исключение базы данных для проверки преобразования в StorageFailure.
class FakeDatabaseException implements DatabaseException {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Запоминает вызовы открытия и сразу вызывает onCreate на [db].
class FakeDatabaseOpener {
  FakeDatabaseOpener([FakeDatabase? db]) : db = db ?? FakeDatabase();

  final FakeDatabase db;
  final List<String> openedPaths = [];
  int? openedVersion;

  Future<Database> call(
    String path, {
    int? version,
    OnDatabaseCreateFn? onCreate,
  }) async {
    openedPaths.add(path);
    openedVersion = version;
    if (onCreate != null) await onCreate(db, version ?? 0);
    return db;
  }
}

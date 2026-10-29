import 'package:rospatent/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

/// Функция открытия БД (по умолчанию sqflite.openDatabase; в тестах подменяется).
typedef DatabaseOpener =
    Future<Database> Function(
      String path, {
      int? version,
      OnDatabaseCreateFn? onCreate,
    });

/// SQLite-хранилище избранного. Схема совместима с предыдущей версией
/// приложения (rospatent.db, таблица favorites), поэтому данные сохраняются.
class FavoritesLocalDataSource {
  FavoritesLocalDataSource({
    Future<String> Function()? pathProvider,
    DatabaseOpener? opener,
  }) : _pathProvider = pathProvider ?? getDatabasesPath,
       _opener = opener ?? openDatabase;

  static const _table = 'favorites';

  final Future<String> Function() _pathProvider;
  final DatabaseOpener _opener;

  Future<Database>? _opening;
  Future<Database> get _db => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await _pathProvider();
    return _opener(
      '$dir/rospatent.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id                 TEXT PRIMARY KEY,
            title              TEXT NOT NULL,
            description        TEXT NOT NULL DEFAULT '',
            application_number TEXT NOT NULL DEFAULT '',
            document_number    INTEGER NOT NULL DEFAULT -1,
            kind               TEXT NOT NULL DEFAULT '',
            guid               TEXT NOT NULL DEFAULT '',
            country            TEXT NOT NULL DEFAULT '',
            lang               TEXT NOT NULL DEFAULT '',
            ipc                TEXT NOT NULL DEFAULT '',
            cpc                TEXT NOT NULL DEFAULT '',
            inventor           TEXT NOT NULL DEFAULT '',
            patentee           TEXT NOT NULL DEFAULT '',
            applicant          TEXT NOT NULL DEFAULT '',
            publication_date   TEXT,
            filing_date        TEXT,
            added_at           INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_favorites_added_at ON $_table(added_at DESC)',
        );
      },
    );
  }

  Future<T> _guard<T>(Future<T> Function(Database db) action) async {
    try {
      return await action(await _db);
    } on DatabaseException {
      throw const StorageFailure();
    }
  }

  Future<List<Map<String, Object?>>> getAll() =>
      _guard((db) => db.query(_table, orderBy: 'added_at DESC'));

  Future<void> upsert(Map<String, Object?> row) => _guard(
    (db) => db.insert(_table, row, conflictAlgorithm: ConflictAlgorithm.replace),
  );

  Future<void> delete(String id) =>
      _guard((db) => db.delete(_table, where: 'id = ?', whereArgs: [id]));

  Future<bool> exists(String id) => _guard((db) async {
    final rows = await db.query(
      _table,
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  });
}

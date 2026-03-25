import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// SQLite database helper for VitalPulse.
///
/// Manages database creation, migrations, and provides access to the
/// [Database] instance for all feature data sources.
final class DatabaseHelper {
  const DatabaseHelper._();

  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._();

  /// Returns the singleton [Database] instance, initializing it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);

    return openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(_routinesTableDdl);
    await db.execute(_habitsTableDdl);
    await db.execute(_habitLogsTableDdl);
    await db.execute(_workoutsTableDdl);
    await db.execute(_weightEntriesTableDdl);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here
  }

  static const _routinesTableDdl = '''
    CREATE TABLE ${AppConstants.routinesTable} (
      id          TEXT PRIMARY KEY,
      title       TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      start_time  TEXT NOT NULL,
      end_time    TEXT NOT NULL,
      days_of_week TEXT NOT NULL DEFAULT '[]',
      color       INTEGER NOT NULL DEFAULT 0,
      created_at  TEXT NOT NULL
    )
  ''';

  static const _habitsTableDdl = '''
    CREATE TABLE ${AppConstants.habitsTable} (
      id          TEXT PRIMARY KEY,
      title       TEXT NOT NULL,
      description TEXT NOT NULL DEFAULT '',
      frequency   TEXT NOT NULL DEFAULT 'daily',
      goal        INTEGER NOT NULL DEFAULT 1,
      color       INTEGER NOT NULL DEFAULT 0,
      icon        INTEGER NOT NULL DEFAULT 0,
      created_at  TEXT NOT NULL
    )
  ''';

  static const _habitLogsTableDdl = '''
    CREATE TABLE ${AppConstants.habitLogsTable} (
      id           TEXT PRIMARY KEY,
      habit_id     TEXT NOT NULL,
      completed_at TEXT NOT NULL,
      note         TEXT NOT NULL DEFAULT '',
      FOREIGN KEY (habit_id) REFERENCES ${AppConstants.habitsTable}(id) ON DELETE CASCADE
    )
  ''';

  static const _workoutsTableDdl = '''
    CREATE TABLE ${AppConstants.workoutsTable} (
      id            TEXT PRIMARY KEY,
      exercise_name TEXT NOT NULL,
      sets          INTEGER NOT NULL DEFAULT 0,
      reps          INTEGER NOT NULL DEFAULT 0,
      weight_kg     REAL NOT NULL DEFAULT 0.0,
      notes         TEXT NOT NULL DEFAULT '',
      logged_at     TEXT NOT NULL
    )
  ''';

  static const _weightEntriesTableDdl = '''
    CREATE TABLE ${AppConstants.weightEntriesTable} (
      id        TEXT PRIMARY KEY,
      weight_kg REAL NOT NULL,
      logged_at TEXT NOT NULL,
      note      TEXT NOT NULL DEFAULT ''
    )
  ''';

  /// Closes the database connection. Useful in tests.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

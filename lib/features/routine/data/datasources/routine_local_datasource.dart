import 'package:sqflite/sqflite.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/core/database/database_helper.dart';
import 'package:vitalpulse/features/routine/data/models/routine_model.dart';

/// SQLite data source for routine entries.
final class RoutineLocalDataSource {
  const RoutineLocalDataSource({required this.databaseHelper});

  final DatabaseHelper databaseHelper;

  Future<Database> get _db => databaseHelper.database;

  Future<List<RoutineModel>> getRoutines() async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.routinesTable,
      orderBy: 'start_time ASC',
    );
    return rows.map(RoutineModel.fromMap).toList();
  }

  Future<List<RoutineModel>> getRoutinesForDay(int dayOfWeek) async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.routinesTable,
      orderBy: 'start_time ASC',
    );
    return rows
        .map(RoutineModel.fromMap)
        .where((m) {
          final entry = m.toEntity();
          return entry.daysOfWeek.contains(dayOfWeek);
        })
        .toList();
  }

  Future<void> insertRoutine(RoutineModel model) async {
    final db = await _db;
    await db.insert(
      AppConstants.routinesTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRoutine(RoutineModel model) async {
    final db = await _db;
    await db.update(
      AppConstants.routinesTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteRoutine(String id) async {
    final db = await _db;
    await db.delete(
      AppConstants.routinesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/core/database/database_helper.dart';
import 'package:vitalpulse/features/habits/data/models/habit_model.dart';

/// Local data source for habits — direct SQLite access layer.
final class HabitLocalDataSource {
  const HabitLocalDataSource({required this.databaseHelper});

  final DatabaseHelper databaseHelper;

  Future<Database> get _db => databaseHelper.database;

  // ── Habits ────────────────────────────────────────────────────────────────

  Future<List<HabitModel>> getHabits() async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.habitsTable,
      orderBy: 'created_at ASC',
    );
    return rows.map(HabitModel.fromMap).toList();
  }

  Future<HabitModel?> getHabitById(String id) async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.habitsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return HabitModel.fromMap(rows.first);
  }

  Future<void> insertHabit(HabitModel model) async {
    final db = await _db;
    await db.insert(
      AppConstants.habitsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateHabit(HabitModel model) async {
    final db = await _db;
    await db.update(
      AppConstants.habitsTable,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteHabit(String id) async {
    final db = await _db;
    await db.delete(
      AppConstants.habitsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Habit Logs ────────────────────────────────────────────────────────────

  Future<List<HabitLogModel>> getLogsForHabit(String habitId) async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.habitLogsTable,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
    );
    return rows.map(HabitLogModel.fromMap).toList();
  }

  Future<void> insertHabitLog(HabitLogModel model) async {
    final db = await _db;
    await db.insert(
      AppConstants.habitLogsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHabitLog(String logId) async {
    final db = await _db;
    await db.delete(
      AppConstants.habitLogsTable,
      where: 'id = ?',
      whereArgs: [logId],
    );
  }

  Future<bool> isCompletedOn(String habitId, DateTime date) async {
    final db = await _db;
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';

    final rows = await db.query(
      AppConstants.habitLogsTable,
      where: 'habit_id = ? AND completed_at LIKE ?',
      whereArgs: [habitId, '$dateStr%'],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/core/database/database_helper.dart';
import 'package:vitalpulse/features/fitness/data/models/fitness_models.dart';

/// SQLite data source for fitness data.
final class FitnessLocalDataSource {
  const FitnessLocalDataSource({required this.databaseHelper});

  final DatabaseHelper databaseHelper;

  Future<Database> get _db => databaseHelper.database;

  // ── Workouts ──────────────────────────────────────────────────────────────

  Future<List<WorkoutModel>> getWorkouts() async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.workoutsTable,
      orderBy: 'logged_at DESC',
    );
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<List<WorkoutModel>> getWorkoutsForDate(DateTime date) async {
    final db = await _db;
    final dateStr = date.toIso8601String().substring(0, 10);
    final rows = await db.query(
      AppConstants.workoutsTable,
      where: 'logged_at LIKE ?',
      whereArgs: ['$dateStr%'],
      orderBy: 'logged_at ASC',
    );
    return rows.map(WorkoutModel.fromMap).toList();
  }

  Future<void> insertWorkout(WorkoutModel model) async {
    final db = await _db;
    await db.insert(
      AppConstants.workoutsTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWorkout(String id) async {
    final db = await _db;
    await db.delete(
      AppConstants.workoutsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Weight entries ────────────────────────────────────────────────────────

  Future<List<WeightEntryModel>> getWeightEntries() async {
    final db = await _db;
    final rows = await db.query(
      AppConstants.weightEntriesTable,
      orderBy: 'logged_at ASC',
    );
    return rows.map(WeightEntryModel.fromMap).toList();
  }

  Future<void> insertWeightEntry(WeightEntryModel model) async {
    final db = await _db;
    await db.insert(
      AppConstants.weightEntriesTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWeightEntry(String id) async {
    final db = await _db;
    await db.delete(
      AppConstants.weightEntriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

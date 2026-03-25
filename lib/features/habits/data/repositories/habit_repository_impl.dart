import 'package:vitalpulse/features/habits/data/datasources/habit_local_datasource.dart';
import 'package:vitalpulse/features/habits/data/models/habit_model.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';

/// Concrete [HabitRepository] backed by SQLite via [HabitLocalDataSource].
final class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl({required this.localDataSource});

  final HabitLocalDataSource localDataSource;

  @override
  Future<List<Habit>> getHabits() async {
    final models = await localDataSource.getHabits();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final model = await localDataSource.getHabitById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addHabit(Habit habit) =>
      localDataSource.insertHabit(HabitModel.fromEntity(habit));

  @override
  Future<void> updateHabit(Habit habit) =>
      localDataSource.updateHabit(HabitModel.fromEntity(habit));

  @override
  Future<void> deleteHabit(String id) => localDataSource.deleteHabit(id);

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    final models = await localDataSource.getLogsForHabit(habitId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addHabitLog(HabitLog log) =>
      localDataSource.insertHabitLog(HabitLogModel.fromEntity(log));

  @override
  Future<void> deleteHabitLog(String logId) =>
      localDataSource.deleteHabitLog(logId);

  @override
  Future<bool> isCompletedOn(String habitId, DateTime date) =>
      localDataSource.isCompletedOn(habitId, date);
}

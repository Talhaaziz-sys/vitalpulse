import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';

/// Abstract contract for the habit repository.
///
/// The data layer provides a concrete implementation that talks to SQLite.
abstract interface class HabitRepository {
  /// Returns all habits stored locally, ordered by creation date.
  Future<List<Habit>> getHabits();

  /// Returns a single habit by its [id], or `null` if not found.
  Future<Habit?> getHabitById(String id);

  /// Persists a new [habit] to the local store.
  Future<void> addHabit(Habit habit);

  /// Updates an existing [habit].
  Future<void> updateHabit(Habit habit);

  /// Deletes the habit with the given [id] and all associated logs.
  Future<void> deleteHabit(String id);

  /// Returns all completion logs for the habit identified by [habitId].
  Future<List<HabitLog>> getLogsForHabit(String habitId);

  /// Appends a completion [log] for a habit.
  Future<void> addHabitLog(HabitLog log);

  /// Removes a specific completion log by its [logId].
  Future<void> deleteHabitLog(String logId);

  /// Returns `true` if the habit [habitId] has been completed on [date].
  Future<bool> isCompletedOn(String habitId, DateTime date);
}

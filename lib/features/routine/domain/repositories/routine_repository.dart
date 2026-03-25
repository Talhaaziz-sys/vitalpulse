import 'package:vitalpulse/features/routine/domain/entities/routine_entry.dart';

/// Abstract contract for the routine repository.
abstract interface class RoutineRepository {
  /// Returns all routine entries, ordered by start time.
  Future<List<RoutineEntry>> getRoutines();

  /// Returns routine entries scheduled for the given [dayOfWeek] (1–7).
  Future<List<RoutineEntry>> getRoutinesForDay(int dayOfWeek);

  /// Persists a new [entry].
  Future<void> addRoutine(RoutineEntry entry);

  /// Updates an existing [entry].
  Future<void> updateRoutine(RoutineEntry entry);

  /// Deletes the entry with the given [id].
  Future<void> deleteRoutine(String id);
}

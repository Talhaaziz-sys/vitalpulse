import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';

/// Abstract contract for the fitness repository.
abstract interface class FitnessRepository {
  // ── Workouts ──────────────────────────────────────────────────────────────
  Future<List<Workout>> getWorkouts();
  Future<List<Workout>> getWorkoutsForDate(DateTime date);
  Future<void> addWorkout(Workout workout);
  Future<void> deleteWorkout(String id);

  // ── Weight entries ────────────────────────────────────────────────────────
  Future<List<WeightEntry>> getWeightEntries();
  Future<void> addWeightEntry(WeightEntry entry);
  Future<void> deleteWeightEntry(String id);
}

import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';
import 'package:vitalpulse/features/fitness/domain/repositories/fitness_repository.dart';

/// Use case: get all workouts.
final class GetWorkoutsUseCase {
  const GetWorkoutsUseCase({required this.repository});
  final FitnessRepository repository;
  Future<List<Workout>> call() => repository.getWorkouts();
}

/// Use case: log a new workout.
final class LogWorkoutUseCase {
  const LogWorkoutUseCase({required this.repository});
  final FitnessRepository repository;
  Future<void> call(Workout workout) => repository.addWorkout(workout);
}

/// Use case: get all weight entries, sorted chronologically.
final class GetWeightEntriesUseCase {
  const GetWeightEntriesUseCase({required this.repository});
  final FitnessRepository repository;
  Future<List<WeightEntry>> call() => repository.getWeightEntries();
}

/// Use case: log a new body weight entry.
final class LogWeightUseCase {
  const LogWeightUseCase({required this.repository});
  final FitnessRepository repository;
  Future<void> call(WeightEntry entry) => repository.addWeightEntry(entry);
}

import 'package:vitalpulse/features/fitness/data/datasources/fitness_local_datasource.dart';
import 'package:vitalpulse/features/fitness/data/models/fitness_models.dart';
import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';
import 'package:vitalpulse/features/fitness/domain/repositories/fitness_repository.dart';

/// Concrete [FitnessRepository] backed by SQLite.
final class FitnessRepositoryImpl implements FitnessRepository {
  const FitnessRepositoryImpl({required this.localDataSource});

  final FitnessLocalDataSource localDataSource;

  @override
  Future<List<Workout>> getWorkouts() async {
    final models = await localDataSource.getWorkouts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsForDate(DateTime date) async {
    final models = await localDataSource.getWorkoutsForDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addWorkout(Workout workout) =>
      localDataSource.insertWorkout(WorkoutModel.fromEntity(workout));

  @override
  Future<void> deleteWorkout(String id) =>
      localDataSource.deleteWorkout(id);

  @override
  Future<List<WeightEntry>> getWeightEntries() async {
    final models = await localDataSource.getWeightEntries();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addWeightEntry(WeightEntry entry) =>
      localDataSource.insertWeightEntry(WeightEntryModel.fromEntity(entry));

  @override
  Future<void> deleteWeightEntry(String id) =>
      localDataSource.deleteWeightEntry(id);
}

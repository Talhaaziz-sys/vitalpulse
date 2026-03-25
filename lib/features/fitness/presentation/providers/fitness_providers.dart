import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/core/database/database_helper.dart';
import 'package:vitalpulse/features/fitness/data/datasources/fitness_local_datasource.dart';
import 'package:vitalpulse/features/fitness/data/repositories/fitness_repository_impl.dart';
import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';
import 'package:vitalpulse/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:uuid/uuid.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final fitnessLocalDataSourceProvider = Provider<FitnessLocalDataSource>(
  (ref) => FitnessLocalDataSource(
    databaseHelper: DatabaseHelper.instance,
  ),
);

final fitnessRepositoryProvider = Provider<FitnessRepository>(
  (ref) => FitnessRepositoryImpl(
    localDataSource: ref.watch(fitnessLocalDataSourceProvider),
  ),
);

// ── Workout notifier ──────────────────────────────────────────────────────────

final workoutNotifierProvider =
    AsyncNotifierProvider.autoDispose<WorkoutNotifier, List<Workout>>(
  WorkoutNotifier.new,
);

class WorkoutNotifier extends AutoDisposeAsyncNotifier<List<Workout>> {
  late FitnessRepository _repository;

  @override
  Future<List<Workout>> build() async {
    _repository = ref.watch(fitnessRepositoryProvider);
    return _repository.getWorkouts();
  }

  Future<void> logWorkout({
    required String exerciseName,
    required int sets,
    required int reps,
    required double weightKg,
    String notes = '',
  }) async {
    const uuid = Uuid();
    final workout = Workout(
      id: uuid.v4(),
      exerciseName: exerciseName,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      notes: notes,
      loggedAt: DateTime.now(),
    );
    await _repository.addWorkout(workout);
    ref.invalidateSelf();
  }

  Future<void> deleteWorkout(String id) async {
    await _repository.deleteWorkout(id);
    ref.invalidateSelf();
  }
}

// ── Weight notifier ───────────────────────────────────────────────────────────

final weightNotifierProvider =
    AsyncNotifierProvider.autoDispose<WeightNotifier, List<WeightEntry>>(
  WeightNotifier.new,
);

class WeightNotifier extends AutoDisposeAsyncNotifier<List<WeightEntry>> {
  late FitnessRepository _repository;

  @override
  Future<List<WeightEntry>> build() async {
    _repository = ref.watch(fitnessRepositoryProvider);
    return _repository.getWeightEntries();
  }

  Future<void> logWeight({
    required double weightKg,
    String note = '',
  }) async {
    const uuid = Uuid();
    final entry = WeightEntry(
      id: uuid.v4(),
      weightKg: weightKg,
      loggedAt: DateTime.now(),
      note: note,
    );
    await _repository.addWeightEntry(entry);
    ref.invalidateSelf();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteWeightEntry(id);
    ref.invalidateSelf();
  }
}

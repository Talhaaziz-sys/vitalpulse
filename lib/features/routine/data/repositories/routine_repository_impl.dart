import 'package:vitalpulse/features/routine/data/datasources/routine_local_datasource.dart';
import 'package:vitalpulse/features/routine/data/models/routine_model.dart';
import 'package:vitalpulse/features/routine/domain/entities/routine_entry.dart';
import 'package:vitalpulse/features/routine/domain/repositories/routine_repository.dart';

/// Concrete [RoutineRepository] backed by SQLite.
final class RoutineRepositoryImpl implements RoutineRepository {
  const RoutineRepositoryImpl({required this.localDataSource});

  final RoutineLocalDataSource localDataSource;

  @override
  Future<List<RoutineEntry>> getRoutines() async {
    final models = await localDataSource.getRoutines();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<RoutineEntry>> getRoutinesForDay(int dayOfWeek) async {
    final models = await localDataSource.getRoutinesForDay(dayOfWeek);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addRoutine(RoutineEntry entry) =>
      localDataSource.insertRoutine(RoutineModel.fromEntity(entry));

  @override
  Future<void> updateRoutine(RoutineEntry entry) =>
      localDataSource.updateRoutine(RoutineModel.fromEntity(entry));

  @override
  Future<void> deleteRoutine(String id) =>
      localDataSource.deleteRoutine(id);
}

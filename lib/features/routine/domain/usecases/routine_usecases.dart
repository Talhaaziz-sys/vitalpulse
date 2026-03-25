import 'package:vitalpulse/features/routine/domain/entities/routine_entry.dart';
import 'package:vitalpulse/features/routine/domain/repositories/routine_repository.dart';

/// Use case: retrieve all routines.
final class GetRoutinesUseCase {
  const GetRoutinesUseCase({required this.repository});
  final RoutineRepository repository;
  Future<List<RoutineEntry>> call() => repository.getRoutines();
}

/// Use case: retrieve routines for a specific day of the week.
final class GetRoutinesForDayUseCase {
  const GetRoutinesForDayUseCase({required this.repository});
  final RoutineRepository repository;
  Future<List<RoutineEntry>> call(int dayOfWeek) =>
      repository.getRoutinesForDay(dayOfWeek);
}

/// Use case: add a new routine entry.
final class AddRoutineUseCase {
  const AddRoutineUseCase({required this.repository});
  final RoutineRepository repository;
  Future<void> call(RoutineEntry entry) => repository.addRoutine(entry);
}

/// Use case: delete a routine entry.
final class DeleteRoutineUseCase {
  const DeleteRoutineUseCase({required this.repository});
  final RoutineRepository repository;
  Future<void> call(String id) => repository.deleteRoutine(id);
}

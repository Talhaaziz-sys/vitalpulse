import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/core/database/database_helper.dart';
import 'package:vitalpulse/features/routine/data/datasources/routine_local_datasource.dart';
import 'package:vitalpulse/features/routine/data/repositories/routine_repository_impl.dart';
import 'package:vitalpulse/features/routine/domain/entities/routine_entry.dart';
import 'package:vitalpulse/features/routine/domain/repositories/routine_repository.dart';
import 'package:vitalpulse/features/routine/domain/usecases/routine_usecases.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final routineLocalDataSourceProvider = Provider<RoutineLocalDataSource>(
  (ref) => RoutineLocalDataSource(
    databaseHelper: DatabaseHelper.instance,
  ),
);

final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepositoryImpl(
    localDataSource: ref.watch(routineLocalDataSourceProvider),
  ),
);

// ── Use cases ─────────────────────────────────────────────────────────────────

final getRoutinesUseCaseProvider = Provider<GetRoutinesUseCase>(
  (ref) => GetRoutinesUseCase(
    repository: ref.watch(routineRepositoryProvider),
  ),
);

final addRoutineUseCaseProvider = Provider<AddRoutineUseCase>(
  (ref) => AddRoutineUseCase(
    repository: ref.watch(routineRepositoryProvider),
  ),
);

final deleteRoutineUseCaseProvider = Provider<DeleteRoutineUseCase>(
  (ref) => DeleteRoutineUseCase(
    repository: ref.watch(routineRepositoryProvider),
  ),
);

// ── Selected day ──────────────────────────────────────────────────────────────

/// Currently selected weekday index (1 = Monday … 7 = Sunday).
final selectedDayProvider = StateProvider<int>(
  (_) => DateTime.now().weekday,
);

// ── Notifier ──────────────────────────────────────────────────────────────────

final routineNotifierProvider =
    AsyncNotifierProvider.autoDispose<RoutineNotifier, List<RoutineEntry>>(
  RoutineNotifier.new,
);

class RoutineNotifier extends AutoDisposeAsyncNotifier<List<RoutineEntry>> {
  late RoutineRepository _repository;

  @override
  Future<List<RoutineEntry>> build() async {
    _repository = ref.watch(routineRepositoryProvider);
    final day = ref.watch(selectedDayProvider);
    return _repository.getRoutinesForDay(day);
  }

  Future<void> addRoutine({
    required String title,
    required String description,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required int color,
  }) async {
    const uuid = Uuid();
    final entry = RoutineEntry(
      id: uuid.v4(),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      daysOfWeek: daysOfWeek,
      color: color,
      createdAt: DateTime.now(),
    );
    await _repository.addRoutine(entry);
    ref.invalidateSelf();
  }

  Future<void> deleteRoutine(String id) async {
    await _repository.deleteRoutine(id);
    ref.invalidateSelf();
  }
}

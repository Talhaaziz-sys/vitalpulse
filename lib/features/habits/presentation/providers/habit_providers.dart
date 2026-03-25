import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/core/database/database_helper.dart';
import 'package:vitalpulse/features/habits/data/datasources/habit_local_datasource.dart';
import 'package:vitalpulse/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_with_stats.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';
import 'package:vitalpulse/features/habits/domain/usecases/add_habit_usecase.dart';
import 'package:vitalpulse/features/habits/domain/usecases/calculate_streak_usecase.dart';
import 'package:vitalpulse/features/habits/domain/usecases/complete_habit_usecase.dart';
import 'package:vitalpulse/features/habits/domain/usecases/get_habits_usecase.dart';
import 'package:uuid/uuid.dart';

// ── Infrastructure providers ─────────────────────────────────────────────────

final databaseHelperProvider = Provider<DatabaseHelper>(
  (_) => DatabaseHelper.instance,
);

final habitLocalDataSourceProvider = Provider<HabitLocalDataSource>(
  (ref) => HabitLocalDataSource(
    databaseHelper: ref.watch(databaseHelperProvider),
  ),
);

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepositoryImpl(
    localDataSource: ref.watch(habitLocalDataSourceProvider),
  ),
);

// ── Use case providers ────────────────────────────────────────────────────────

final getHabitsUseCaseProvider = Provider<GetHabitsUseCase>(
  (ref) => GetHabitsUseCase(
    repository: ref.watch(habitRepositoryProvider),
  ),
);

final addHabitUseCaseProvider = Provider<AddHabitUseCase>(
  (ref) => AddHabitUseCase(
    repository: ref.watch(habitRepositoryProvider),
  ),
);

final completeHabitUseCaseProvider = Provider<CompleteHabitUseCase>(
  (ref) => CompleteHabitUseCase(
    repository: ref.watch(habitRepositoryProvider),
  ),
);

final calculateStreakUseCaseProvider = Provider<CalculateStreakUseCase>(
  (ref) => CalculateStreakUseCase(
    repository: ref.watch(habitRepositoryProvider),
  ),
);

// ── State providers ───────────────────────────────────────────────────────────

/// Async provider that loads all habits with their streak stats.
final habitsWithStatsProvider =
    FutureProvider.autoDispose<List<HabitWithStats>>((ref) async {
  final habits = await ref.watch(getHabitsUseCaseProvider).call();
  final calculateStreak = ref.watch(calculateStreakUseCaseProvider);
  return Future.wait(habits.map(calculateStreak.call));
});

/// Notifier that handles habit CRUD + completion mutations.
final habitNotifierProvider =
    AsyncNotifierProvider.autoDispose<HabitNotifier, List<HabitWithStats>>(
  HabitNotifier.new,
);

/// Async notifier for habits that refreshes on mutations.
class HabitNotifier extends AutoDisposeAsyncNotifier<List<HabitWithStats>> {
  late HabitRepository _repository;
  late CalculateStreakUseCase _calculateStreak;

  @override
  Future<List<HabitWithStats>> build() async {
    _repository = ref.watch(habitRepositoryProvider);
    _calculateStreak = ref.watch(calculateStreakUseCaseProvider);
    return _loadHabitsWithStats();
  }

  Future<List<HabitWithStats>> _loadHabitsWithStats() async {
    final habits = await _repository.getHabits();
    return Future.wait(habits.map(_calculateStreak.call));
  }

  /// Adds a new habit and refreshes the list.
  Future<void> addHabit({
    required String title,
    required String description,
    required HabitFrequency frequency,
    required int goal,
    required int color,
    required int iconCodePoint,
  }) async {
    const uuid = Uuid();
    final habit = Habit(
      id: uuid.v4(),
      title: title,
      description: description,
      frequency: frequency,
      goal: goal,
      color: color,
      iconCodePoint: iconCodePoint,
      createdAt: DateTime.now(),
    );
    await _repository.addHabit(habit);
    ref.invalidateSelf();
  }

  /// Toggles today's completion for [habit].
  Future<void> toggleCompletion(Habit habit) async {
    final today = DateTime.now();
    final alreadyDone = await _repository.isCompletedOn(habit.id, today);

    if (alreadyDone) {
      final logs = await _repository.getLogsForHabit(habit.id);
      final todayLog = logs.firstWhere(
        (l) =>
            l.completedAt.year == today.year &&
            l.completedAt.month == today.month &&
            l.completedAt.day == today.day,
      );
      await _repository.deleteHabitLog(todayLog.id);
    } else {
      const uuid = Uuid();
      final log = HabitLog(
        id: uuid.v4(),
        habitId: habit.id,
        completedAt: today,
      );
      await _repository.addHabitLog(log);
    }
    ref.invalidateSelf();
  }

  /// Deletes a habit and refreshes the list.
  Future<void> deleteHabit(String habitId) async {
    await _repository.deleteHabit(habitId);
    ref.invalidateSelf();
  }
}

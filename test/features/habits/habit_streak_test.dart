// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';
import 'package:vitalpulse/features/habits/domain/usecases/calculate_streak_usecase.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

/// In-memory [HabitRepository] for testing, backed by simple lists.
final class FakeHabitRepository implements HabitRepository {
  FakeHabitRepository({
    List<Habit>? habits,
    List<HabitLog>? logs,
  })  : _habits = habits ?? [],
        _logs = logs ?? [];

  final List<Habit> _habits;
  final List<HabitLog> _logs;

  @override
  Future<List<Habit>> getHabits() async => List.unmodifiable(_habits);

  @override
  Future<Habit?> getHabitById(String id) async =>
      _habits.where((h) => h.id == id).firstOrNull;

  @override
  Future<void> addHabit(Habit habit) async => _habits.add(habit);

  @override
  Future<void> updateHabit(Habit habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) _habits[index] = habit;
  }

  @override
  Future<void> deleteHabit(String id) async => _habits.removeWhere((h) => h.id == id);

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) async =>
      _logs.where((l) => l.habitId == habitId).toList();

  @override
  Future<void> addHabitLog(HabitLog log) async => _logs.add(log);

  @override
  Future<void> deleteHabitLog(String logId) async =>
      _logs.removeWhere((l) => l.id == logId);

  @override
  Future<bool> isCompletedOn(String habitId, DateTime date) async =>
      _logs.any(
        (l) =>
            l.habitId == habitId &&
            l.completedAt.year == date.year &&
            l.completedAt.month == date.month &&
            l.completedAt.day == date.day,
      );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Habit _makeHabit({HabitFrequency frequency = HabitFrequency.daily}) => Habit(
      id: 'habit-1',
      title: 'Test Habit',
      description: '',
      frequency: frequency,
      goal: 1,
      color: 0xFF00D4FF,
      iconCodePoint: 0xe3f4,
      createdAt: DateTime(2026, 1, 1),
    );

HabitLog _logOn(DateTime date) => HabitLog(
      id: 'log-${date.millisecondsSinceEpoch}',
      habitId: 'habit-1',
      completedAt: date,
    );

/// Returns a fixed "today" for deterministic testing: 2026-03-25 (Wednesday).
DateTime get _today => DateTime(2026, 3, 25);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('CalculateStreakUseCase – daily habits', () {
    late CalculateStreakUseCase useCase;

    setUp(() {
      // Each test sets its own repository via `useCase = ...`
    });

    test('returns zero streaks when there are no logs', () async {
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.completedToday, false);
      expect(result.totalCompletions, 0);
    });

    test('streak of 1 when only today is logged', () async {
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(
          logs: [_logOn(_today)],
        ),
      );

      // Override "today" by using the same date for the log
      final habit = _makeHabit();
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: habit.id,
          completedAt: DateTime.now(),
        ),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(habit);

      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.completedToday, true);
    });

    test('streak of 5 for 5 consecutive days ending today', () async {
      final today = DateTime.now();
      final logs = List.generate(
        5,
        (i) => HabitLog(
          id: 'l$i',
          habitId: 'habit-1',
          completedAt: today.subtract(Duration(days: i)),
        ),
      );
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.currentStreak, 5);
      expect(result.longestStreak, 5);
    });

    test('grace period: streak continues when today is not yet logged', () async {
      final today = DateTime.now();
      // Logs for yesterday + 4 days prior = 5 consecutive days not including today
      final logs = List.generate(
        5,
        (i) => HabitLog(
          id: 'l$i',
          habitId: 'habit-1',
          completedAt: today.subtract(Duration(days: i + 1)),
        ),
      );
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      // Should NOT reset to 0 because of the grace period rule
      expect(result.currentStreak, 5);
      expect(result.completedToday, false);
    });

    test('streak resets after a gap of 2+ days', () async {
      final today = DateTime.now();
      // Last completion was 3 days ago
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'habit-1',
          completedAt: today.subtract(const Duration(days: 3)),
        ),
        HabitLog(
          id: 'l2',
          habitId: 'habit-1',
          completedAt: today.subtract(const Duration(days: 4)),
        ),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.currentStreak, 0);
    });

    test('longest streak is independent of current streak', () async {
      final today = DateTime.now();
      // Old 7-day streak (10–16 days ago), then a 2-day streak yesterday–today
      final logs = <HabitLog>[
        ...List.generate(
          7,
          (i) => HabitLog(
            id: 'old$i',
            habitId: 'habit-1',
            completedAt: today.subtract(Duration(days: 10 + i)),
          ),
        ),
        HabitLog(
          id: 'cur0',
          habitId: 'habit-1',
          completedAt: today,
        ),
        HabitLog(
          id: 'cur1',
          habitId: 'habit-1',
          completedAt: today.subtract(const Duration(days: 1)),
        ),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.currentStreak, 2);
      expect(result.longestStreak, 7);
    });

    test('duplicate logs on the same day count as one day in streak', () async {
      final today = DateTime.now();
      final logs = [
        HabitLog(
          id: 'l1a',
          habitId: 'habit-1',
          completedAt: today,
        ),
        HabitLog(
          id: 'l1b',
          habitId: 'habit-1',
          // Second log on same day, different hour
          completedAt: today.add(const Duration(hours: 2)),
        ),
        HabitLog(
          id: 'l2',
          habitId: 'habit-1',
          completedAt: today.subtract(const Duration(days: 1)),
        ),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.currentStreak, 2);
    });

    test('completedToday is true when logged today', () async {
      final logs = [
        HabitLog(
          id: 'l1',
          habitId: 'habit-1',
          completedAt: DateTime.now(),
        ),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.completedToday, isTrue);
    });

    test('totalCompletions reflects all log entries', () async {
      final today = DateTime.now();
      final logs = List.generate(
        10,
        (i) => HabitLog(
          id: 'l$i',
          habitId: 'habit-1',
          completedAt: today.subtract(Duration(days: i)),
        ),
      );
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(_makeHabit());

      expect(result.totalCompletions, 10);
    });
  });

  group('CalculateStreakUseCase – weekly habits', () {
    late CalculateStreakUseCase useCase;

    /// Returns the Monday of the week containing [date].
    DateTime _mondayOf(DateTime date) {
      final d = DateTime(date.year, date.month, date.day);
      return d.subtract(Duration(days: d.weekday - DateTime.monday));
    }

    test('weekly streak of 3 for 3 consecutive weeks', () async {
      final today = DateTime.now();
      final thisMonday = _mondayOf(today);
      final logs = [
        _logOn(thisMonday),
        _logOn(thisMonday.subtract(const Duration(days: 7))),
        _logOn(thisMonday.subtract(const Duration(days: 14))),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(
        _makeHabit(frequency: HabitFrequency.weekly),
      );

      expect(result.currentStreak, 3);
      expect(result.longestStreak, greaterThanOrEqualTo(3));
    });

    test('weekly streak is 0 when last log was 2 weeks ago with no grace', () async {
      final today = DateTime.now();
      final thisMonday = _mondayOf(today);
      final logs = [
        _logOn(thisMonday.subtract(const Duration(days: 14))),
      ];
      useCase = CalculateStreakUseCase(
        repository: FakeHabitRepository(logs: logs),
      );
      final result = await useCase.call(
        _makeHabit(frequency: HabitFrequency.weekly),
      );

      expect(result.currentStreak, 0);
    });
  });
}

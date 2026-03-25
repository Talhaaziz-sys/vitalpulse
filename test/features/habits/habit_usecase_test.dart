// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';
import 'package:vitalpulse/features/habits/domain/usecases/add_habit_usecase.dart';
import 'package:vitalpulse/features/habits/domain/usecases/complete_habit_usecase.dart';
import 'package:vitalpulse/features/habits/domain/usecases/get_habits_usecase.dart';

// ── Fake repository ───────────────────────────────────────────────────────────

final class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository({List<Habit>? habits, List<HabitLog>? logs})
      : _habits = habits ?? [],
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
  Future<void> deleteHabit(String id) async =>
      _habits.removeWhere((h) => h.id == id);

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

Habit _makeHabit({String id = 'h1', String title = 'Push-ups'}) => Habit(
      id: id,
      title: title,
      description: '',
      frequency: HabitFrequency.daily,
      goal: 1,
      color: 0xFF00D4FF,
      iconCodePoint: 0xe574,
      createdAt: DateTime(2026, 1, 1),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── AddHabitUseCase ────────────────────────────────────────────────────────

  group('AddHabitUseCase', () {
    test('adds a habit to the repository', () async {
      final repo = _FakeHabitRepository();
      final useCase = AddHabitUseCase(repository: repo);
      final habit = _makeHabit();

      await useCase.call(habit);

      final habits = await repo.getHabits();
      expect(habits, hasLength(1));
      expect(habits.first, equals(habit));
    });

    test('adding multiple habits results in all being stored', () async {
      final repo = _FakeHabitRepository();
      final useCase = AddHabitUseCase(repository: repo);

      await useCase.call(_makeHabit(id: 'h1', title: 'Push-ups'));
      await useCase.call(_makeHabit(id: 'h2', title: 'Squats'));
      await useCase.call(_makeHabit(id: 'h3', title: 'Pull-ups'));

      final habits = await repo.getHabits();
      expect(habits, hasLength(3));
      expect(habits.map((h) => h.title), containsAll(['Push-ups', 'Squats', 'Pull-ups']));
    });
  });

  // ── GetHabitsUseCase ───────────────────────────────────────────────────────

  group('GetHabitsUseCase', () {
    test('returns empty list when no habits exist', () async {
      final useCase = GetHabitsUseCase(repository: _FakeHabitRepository());
      final habits = await useCase.call();
      expect(habits, isEmpty);
    });

    test('returns all stored habits', () async {
      final seed = [
        _makeHabit(id: 'h1', title: 'Run'),
        _makeHabit(id: 'h2', title: 'Stretch'),
      ];
      final useCase = GetHabitsUseCase(
        repository: _FakeHabitRepository(habits: seed),
      );
      final habits = await useCase.call();
      expect(habits, hasLength(2));
      expect(habits.map((h) => h.id), containsAll(['h1', 'h2']));
    });
  });

  // ── CompleteHabitUseCase ───────────────────────────────────────────────────

  group('CompleteHabitUseCase', () {
    test('adds a log entry for the given habit', () async {
      final repo = _FakeHabitRepository(habits: [_makeHabit()]);
      final useCase = CompleteHabitUseCase(repository: repo);
      final log = HabitLog(
        id: 'log-1',
        habitId: 'h1',
        completedAt: DateTime.now(),
      );

      await useCase.call(log);

      final logs = await repo.getLogsForHabit('h1');
      expect(logs, hasLength(1));
      expect(logs.first.id, 'log-1');
    });

    test('multiple completions on different days are all recorded', () async {
      final repo = _FakeHabitRepository(habits: [_makeHabit()]);
      final useCase = CompleteHabitUseCase(repository: repo);
      final today = DateTime.now();

      for (var i = 0; i < 5; i++) {
        await useCase.call(
          HabitLog(
            id: 'log-$i',
            habitId: 'h1',
            completedAt: today.subtract(Duration(days: i)),
          ),
        );
      }

      final logs = await repo.getLogsForHabit('h1');
      expect(logs, hasLength(5));
    });

    test('isCompletedOn returns true after logging today', () async {
      final today = DateTime.now();
      final repo = _FakeHabitRepository(habits: [_makeHabit()]);
      final useCase = CompleteHabitUseCase(repository: repo);

      await useCase.call(
        HabitLog(id: 'log-1', habitId: 'h1', completedAt: today),
      );

      final completed = await repo.isCompletedOn('h1', today);
      expect(completed, isTrue);
    });

    test('isCompletedOn returns false for a different day', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final repo = _FakeHabitRepository(habits: [_makeHabit()]);
      final useCase = CompleteHabitUseCase(repository: repo);

      await useCase.call(
        HabitLog(id: 'log-1', habitId: 'h1', completedAt: today),
      );

      final completed = await repo.isCompletedOn('h1', yesterday);
      expect(completed, isFalse);
    });
  });

  // ── Repository: deleteHabitLog ─────────────────────────────────────────────

  group('HabitRepository – deleteHabitLog (via FakeHabitRepository)', () {
    test('removes the log with the matching id', () async {
      final log = HabitLog(
        id: 'log-1',
        habitId: 'h1',
        completedAt: DateTime.now(),
      );
      final repo = _FakeHabitRepository(habits: [_makeHabit()], logs: [log]);

      await repo.deleteHabitLog('log-1');

      final logs = await repo.getLogsForHabit('h1');
      expect(logs, isEmpty);
    });

    test('deleting a non-existent log id leaves other logs intact', () async {
      final log = HabitLog(
        id: 'log-1',
        habitId: 'h1',
        completedAt: DateTime.now(),
      );
      final repo = _FakeHabitRepository(habits: [_makeHabit()], logs: [log]);

      await repo.deleteHabitLog('does-not-exist');

      final logs = await repo.getLogsForHabit('h1');
      expect(logs, hasLength(1));
    });
  });

  // ── Repository: deleteHabit ────────────────────────────────────────────────

  group('HabitRepository – deleteHabit (via FakeHabitRepository)', () {
    test('removes the habit with matching id', () async {
      final repo = _FakeHabitRepository(
        habits: [_makeHabit(id: 'h1'), _makeHabit(id: 'h2')],
      );

      await repo.deleteHabit('h1');

      final habits = await repo.getHabits();
      expect(habits, hasLength(1));
      expect(habits.first.id, 'h2');
    });

    test('getHabitById returns null for deleted habit', () async {
      final repo = _FakeHabitRepository(habits: [_makeHabit()]);
      await repo.deleteHabit('h1');
      final result = await repo.getHabitById('h1');
      expect(result, isNull);
    });

    test('getHabitById returns the correct habit', () async {
      final repo = _FakeHabitRepository(
        habits: [_makeHabit(id: 'h1'), _makeHabit(id: 'h2')],
      );
      final result = await repo.getHabitById('h2');
      expect(result?.id, 'h2');
    });

    test('updateHabit changes the title in place', () async {
      final repo = _FakeHabitRepository(habits: [_makeHabit()]);
      final updated = _makeHabit().copyWith(title: 'Burpees');
      await repo.updateHabit(updated);
      final result = await repo.getHabitById('h1');
      expect(result?.title, 'Burpees');
    });
  });
}

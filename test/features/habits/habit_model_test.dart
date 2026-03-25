// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';
import 'package:vitalpulse/features/habits/data/models/habit_model.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';

void main() {
  // ── HabitModel ─────────────────────────────────────────────────────────────

  group('HabitModel – fromMap', () {
    test('deserializes a complete row correctly', () {
      final map = {
        'id': 'h1',
        'title': 'Morning Run',
        'description': 'Run 5 km',
        'frequency': 'daily',
        'goal': 1,
        'color': 0xFF00D4FF,
        'icon': 0xe574,
        'created_at': '2026-01-15T00:00:00.000',
      };
      final model = HabitModel.fromMap(map);
      expect(model.id, 'h1');
      expect(model.title, 'Morning Run');
      expect(model.description, 'Run 5 km');
      expect(model.frequency, 'daily');
      expect(model.goal, 1);
      expect(model.color, 0xFF00D4FF);
      expect(model.icon, 0xe574);
      expect(model.createdAt, '2026-01-15T00:00:00.000');
    });

    test('defaults description to empty string when null', () {
      final map = {
        'id': 'h2',
        'title': 'Meditate',
        'frequency': 'daily',
        'goal': 1,
        'color': 0xFF8A2BE2,
        'icon': 0xe047,
        'created_at': '2026-02-01T00:00:00.000',
      };
      final model = HabitModel.fromMap(map);
      expect(model.description, '');
    });

    test('defaults frequency to daily when null', () {
      final map = {
        'id': 'h3',
        'title': 'Read',
        'goal': 1,
        'color': 0,
        'icon': 0,
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = HabitModel.fromMap(map);
      expect(model.frequency, 'daily');
    });

    test('defaults goal to 1 when null', () {
      final map = {
        'id': 'h4',
        'title': 'Journal',
        'color': 0,
        'icon': 0,
        'created_at': '2026-01-01T00:00:00.000',
      };
      final model = HabitModel.fromMap(map);
      expect(model.goal, 1);
    });
  });

  group('HabitModel – toMap', () {
    test('serializes back to a map with all expected keys', () {
      final model = HabitModel(
        id: 'h1',
        title: 'Push-ups',
        description: '100 per day',
        frequency: 'daily',
        goal: 1,
        color: 0xFF00D4FF,
        icon: 0xe574,
        createdAt: '2026-01-15T00:00:00.000',
      );
      final map = model.toMap();
      expect(map['id'], 'h1');
      expect(map['title'], 'Push-ups');
      expect(map['description'], '100 per day');
      expect(map['frequency'], 'daily');
      expect(map['goal'], 1);
      expect(map['color'], 0xFF00D4FF);
      expect(map['icon'], 0xe574);
      expect(map['created_at'], '2026-01-15T00:00:00.000');
    });
  });

  group('HabitModel – round-trip: fromEntity → toMap → fromMap → toEntity', () {
    final habit = Habit(
      id: 'h1',
      title: 'Stretching',
      description: '10 minutes',
      frequency: HabitFrequency.weekly,
      goal: 3,
      color: 0xFF00E676,
      iconCodePoint: 0xe574,
      createdAt: DateTime(2026, 3, 1),
    );

    test('round-trip preserves all fields for a daily habit', () {
      final dailyHabit = habit.copyWith(frequency: HabitFrequency.daily);
      final model = HabitModel.fromEntity(dailyHabit);
      final map = model.toMap();
      final recovered = HabitModel.fromMap(map).toEntity();
      expect(recovered.id, dailyHabit.id);
      expect(recovered.title, dailyHabit.title);
      expect(recovered.description, dailyHabit.description);
      expect(recovered.frequency, HabitFrequency.daily);
      expect(recovered.goal, dailyHabit.goal);
      expect(recovered.color, dailyHabit.color);
      expect(recovered.iconCodePoint, dailyHabit.iconCodePoint);
    });

    test('round-trip preserves weekly frequency', () {
      final model = HabitModel.fromEntity(habit);
      final map = model.toMap();
      final recovered = HabitModel.fromMap(map).toEntity();
      expect(recovered.frequency, HabitFrequency.weekly);
    });

    test('tableName returns the habits table constant', () {
      expect(HabitModel.tableName, 'habits');
    });
  });

  // ── HabitLogModel ─────────────────────────────────────────────────────────

  group('HabitLogModel – fromMap', () {
    test('deserializes a complete row correctly', () {
      final map = {
        'id': 'log-1',
        'habit_id': 'h1',
        'completed_at': '2026-03-25T08:30:00.000',
        'note': 'Great session',
      };
      final model = HabitLogModel.fromMap(map);
      expect(model.id, 'log-1');
      expect(model.habitId, 'h1');
      expect(model.completedAt, '2026-03-25T08:30:00.000');
      expect(model.note, 'Great session');
    });

    test('defaults note to empty string when null', () {
      final map = {
        'id': 'log-2',
        'habit_id': 'h1',
        'completed_at': '2026-03-24T09:00:00.000',
      };
      final model = HabitLogModel.fromMap(map);
      expect(model.note, '');
    });
  });

  group('HabitLogModel – toMap', () {
    test('produces expected keys and values', () {
      final model = HabitLogModel(
        id: 'log-1',
        habitId: 'h1',
        completedAt: '2026-03-25T08:30:00.000',
        note: 'Done',
      );
      final map = model.toMap();
      expect(map['id'], 'log-1');
      expect(map['habit_id'], 'h1');
      expect(map['completed_at'], '2026-03-25T08:30:00.000');
      expect(map['note'], 'Done');
    });
  });

  group('HabitLogModel – round-trip: fromEntity → toMap → fromMap → toEntity', () {
    test('preserves all HabitLog fields', () {
      final logEntity = HabitLog(
        id: 'log-1',
        habitId: 'h1',
        completedAt: DateTime(2026, 3, 25, 8, 30),
        note: 'Felt great',
      );
      final model = HabitLogModel.fromEntity(logEntity);
      final map = model.toMap();
      final recovered = HabitLogModel.fromMap(map).toEntity();
      expect(recovered.id, logEntity.id);
      expect(recovered.habitId, logEntity.habitId);
      expect(recovered.completedAt.year, logEntity.completedAt.year);
      expect(recovered.completedAt.month, logEntity.completedAt.month);
      expect(recovered.completedAt.day, logEntity.completedAt.day);
      expect(recovered.note, logEntity.note);
    });

    test('tableName returns the habit_logs table constant', () {
      expect(HabitLogModel.tableName, 'habit_logs');
    });
  });
}

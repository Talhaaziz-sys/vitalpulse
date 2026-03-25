// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_with_stats.dart';

void main() {
  // ── Habit entity ──────────────────────────────────────────────────────────

  group('Habit entity', () {
    final base = Habit(
      id: 'h1',
      title: 'Push-ups',
      description: '100 push-ups every morning',
      frequency: HabitFrequency.daily,
      goal: 1,
      color: 0xFF00D4FF,
      iconCodePoint: Icons.fitness_center.codePoint,
      createdAt: DateTime(2026, 1, 15),
    );

    test('equality: two instances with the same fields are equal', () {
      final copy = Habit(
        id: 'h1',
        title: 'Push-ups',
        description: '100 push-ups every morning',
        frequency: HabitFrequency.daily,
        goal: 1,
        color: 0xFF00D4FF,
        iconCodePoint: Icons.fitness_center.codePoint,
        createdAt: DateTime(2026, 1, 15),
      );
      expect(base, equals(copy));
    });

    test('equality: different ids are not equal', () {
      final other = base.copyWith(id: 'h2');
      expect(base, isNot(equals(other)));
    });

    test('copyWith returns identical object when no fields change', () {
      final copy = base.copyWith();
      expect(copy, equals(base));
    });

    test('copyWith replaces individual fields', () {
      final updated = base.copyWith(title: 'Squats', goal: 3);
      expect(updated.title, 'Squats');
      expect(updated.goal, 3);
      // Unchanged fields
      expect(updated.id, base.id);
      expect(updated.frequency, base.frequency);
    });

    test('displayColor returns correct Color from ARGB int', () {
      expect(base.displayColor, equals(const Color(0xFF00D4FF)));
    });

    test('displayIcon returns MaterialIcons IconData', () {
      final icon = base.displayIcon;
      expect(icon.codePoint, Icons.fitness_center.codePoint);
      expect(icon.fontFamily, 'MaterialIcons');
    });

    test('frequency enum: daily and weekly are distinct', () {
      final weekly = base.copyWith(frequency: HabitFrequency.weekly);
      expect(weekly.frequency, HabitFrequency.weekly);
      expect(base.frequency, HabitFrequency.daily);
    });

    test('props list drives equality and hashCode', () {
      final a = base;
      final b = base.copyWith();
      expect(a.props, b.props);
      expect(a.hashCode, b.hashCode);
    });

    test('preview factory creates a valid Habit with sensible defaults', () {
      final preview = Habit.preview();
      expect(preview.id, 'preview');
      expect(preview.goal, 1);
      expect(preview.frequency, HabitFrequency.daily);
    });

    test('preview factory accepts custom id and title', () {
      final preview = Habit.preview(id: 'test-id', title: 'Meditation');
      expect(preview.id, 'test-id');
      expect(preview.title, 'Meditation');
    });
  });

  // ── HabitLog entity ───────────────────────────────────────────────────────

  group('HabitLog entity', () {
    final log = HabitLog(
      id: 'log-1',
      habitId: 'h1',
      completedAt: DateTime(2026, 3, 25, 8, 30),
      note: 'Felt great!',
    );

    test('equality: same fields are equal', () {
      final copy = HabitLog(
        id: 'log-1',
        habitId: 'h1',
        completedAt: DateTime(2026, 3, 25, 8, 30),
        note: 'Felt great!',
      );
      expect(log, equals(copy));
    });

    test('equality: different note are not equal', () {
      final different = log.copyWith(note: 'Different note');
      expect(log, isNot(equals(different)));
    });

    test('note defaults to empty string when not provided', () {
      final withoutNote = HabitLog(
        id: 'log-2',
        habitId: 'h1',
        completedAt: DateTime(2026, 3, 25),
      );
      expect(withoutNote.note, '');
    });

    test('copyWith updates individual fields correctly', () {
      final updated = log.copyWith(note: 'Updated note');
      expect(updated.note, 'Updated note');
      expect(updated.id, log.id);
      expect(updated.habitId, log.habitId);
      expect(updated.completedAt, log.completedAt);
    });

    test('completedAt stores full datetime including time component', () {
      expect(log.completedAt.hour, 8);
      expect(log.completedAt.minute, 30);
    });

    test('props list contains all fields', () {
      expect(log.props, [log.id, log.habitId, log.completedAt, log.note]);
    });
  });

  // ── HabitWithStats entity ─────────────────────────────────────────────────

  group('HabitWithStats entity', () {
    final habit = Habit.preview(id: 'h1');
    final stats = HabitWithStats(
      habit: habit,
      currentStreak: 7,
      longestStreak: 14,
      completedToday: true,
      totalCompletions: 30,
    );

    test('equality: same fields are equal', () {
      final copy = HabitWithStats(
        habit: habit,
        currentStreak: 7,
        longestStreak: 14,
        completedToday: true,
        totalCompletions: 30,
      );
      expect(stats, equals(copy));
    });

    test('longestStreak is independent of currentStreak', () {
      expect(stats.longestStreak, greaterThanOrEqualTo(stats.currentStreak));
    });

    test('props list drives equality', () {
      expect(
        stats.props,
        [habit, 7, 14, true, 30],
      );
    });

    test('HabitWithStats with zero stats is valid', () {
      final empty = HabitWithStats(
        habit: habit,
        currentStreak: 0,
        longestStreak: 0,
        completedToday: false,
        totalCompletions: 0,
      );
      expect(empty.currentStreak, 0);
      expect(empty.completedToday, isFalse);
    });
  });
}

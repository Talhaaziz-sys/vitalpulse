import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_with_stats.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';

/// Use case that calculates the current and longest streaks for a habit.
///
/// ### Streak Algorithm
///
/// For a **daily** habit:
/// 1. Fetch all completion logs for the habit, sorted descending by date.
/// 2. Start from today and walk backwards day by day.
/// 3. For each day, check if there is at least one log entry on that date.
/// 4. Count consecutive days with at least one log — this is the **current streak**.
///    - If today has no entry but yesterday does, today is a "partial" day and
///      the streak continues from yesterday (grace period).
/// 5. The **longest streak** is the maximum consecutive sequence across all logs.
///
/// For a **weekly** habit:
/// The same logic applies but at week granularity — each calendar week
/// (Monday–Sunday) counts as one period.
final class CalculateStreakUseCase {
  const CalculateStreakUseCase({required this.repository});

  final HabitRepository repository;

  /// Computes [HabitWithStats] for the given [habit].
  Future<HabitWithStats> call(Habit habit) async {
    final logs = await repository.getLogsForHabit(habit.id);

    if (logs.isEmpty) {
      return HabitWithStats(
        habit: habit,
        currentStreak: 0,
        longestStreak: 0,
        completedToday: false,
        totalCompletions: logs.length,
      );
    }

    final today = _dateOnly(DateTime.now());

    final (currentStreak, longestStreak) = habit.frequency == HabitFrequency.daily
        ? _calculateDailyStreaks(logs, today)
        : _calculateWeeklyStreaks(logs, today);

    final completedToday = logs.any(
      (l) => _dateOnly(l.completedAt) == today,
    );

    return HabitWithStats(
      habit: habit,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      completedToday: completedToday,
      totalCompletions: logs.length,
    );
  }

  /// Calculates daily streaks and returns `(currentStreak, longestStreak)`.
  (int current, int longest) _calculateDailyStreaks(
    List<HabitLog> logs,
    DateTime today,
  ) {
    // Build a set of unique dates that have at least one completion.
    final completedDates = <DateTime>{
      for (final log in logs) _dateOnly(log.completedAt),
    };

    // ── Current streak ──────────────────────────────────────────────────────
    // Start from today. If today has no entry, we allow a 1-day grace period
    // by starting from yesterday (the streak is still alive if yesterday has
    // an entry and today hasn't been reached yet).
    var currentStreak = 0;
    var checkDate = today;

    if (!completedDates.contains(checkDate)) {
      // No entry today — grace period: look at yesterday as starting point.
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (completedDates.contains(checkDate)) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // ── Longest streak ───────────────────────────────────────────────────────
    final longest = _longestDailyStreak(completedDates);

    return (currentStreak, longest);
  }

  /// Iterates over all completed dates to find the longest consecutive run.
  int _longestDailyStreak(Set<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;

    final sorted = completedDates.toList()..sort();
    var longest = 1;
    var current = 1;

    for (var i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  /// Calculates weekly streaks. Returns `(currentStreak, longestStreak)`.
  (int current, int longest) _calculateWeeklyStreaks(
    List<HabitLog> logs,
    DateTime today,
  ) {
    // Build a set of week-start dates (Monday) that have at least one entry.
    final completedWeeks = <DateTime>{
      for (final log in logs) _startOfWeek(log.completedAt),
    };

    final thisWeek = _startOfWeek(today);
    var currentStreak = 0;
    var checkWeek = thisWeek;

    if (!completedWeeks.contains(checkWeek)) {
      // Current week not yet complete — grace period: start from last week.
      checkWeek = thisWeek.subtract(const Duration(days: 7));
    }

    while (completedWeeks.contains(checkWeek)) {
      currentStreak++;
      checkWeek = checkWeek.subtract(const Duration(days: 7));
    }

    // Longest weekly streak — computed independently so that a broken current
    // streak does not hide a larger historical run.
    final sorted = completedWeeks.toList()..sort();
    var longest = sorted.isEmpty ? 0 : 1; // every logged week is at least 1
    var runCurrent = 1;
    for (var i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 7) {
        runCurrent++;
        if (runCurrent > longest) longest = runCurrent;
      } else if (diff > 7) {
        runCurrent = 1;
      }
    }
    // Ensure current streak never exceeds the recorded longest.
    if (currentStreak > longest) longest = currentStreak;

    return (currentStreak, longest);
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime _startOfWeek(DateTime dt) {
    final d = _dateOnly(dt);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }
}

/// Result object that bundles a [Habit] with its computed streak and
/// today's completion count.
library;

import 'package:equatable/equatable.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';

/// Enriched view model bundling a habit with its live metrics.
final class HabitWithStats extends Equatable {
  const HabitWithStats({
    required this.habit,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedToday,
    required this.totalCompletions,
  });

  /// The underlying habit entity.
  final Habit habit;

  /// Number of consecutive days/periods the habit has been completed.
  final int currentStreak;

  /// Longest consecutive streak ever recorded.
  final int longestStreak;

  /// Whether the habit has been completed today.
  final bool completedToday;

  /// All-time total completion count.
  final int totalCompletions;

  @override
  List<Object?> get props => [
        habit,
        currentStreak,
        longestStreak,
        completedToday,
        totalCompletions,
      ];
}

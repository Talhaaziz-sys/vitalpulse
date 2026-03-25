import 'package:equatable/equatable.dart';

/// Domain entity representing a single completion record for a habit.
final class HabitLog extends Equatable {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.completedAt,
    this.note = '',
  });

  /// Unique identifier (UUID).
  final String id;

  /// ID of the [Habit] this log belongs to.
  final String habitId;

  /// The date on which the habit was completed (stored as ISO date string).
  final DateTime completedAt;

  /// Optional note attached to this completion.
  final String note;

  /// Returns a copy with the given fields replaced.
  HabitLog copyWith({
    String? id,
    String? habitId,
    DateTime? completedAt,
    String? note,
  }) =>
      HabitLog(
        id: id ?? this.id,
        habitId: habitId ?? this.habitId,
        completedAt: completedAt ?? this.completedAt,
        note: note ?? this.note,
      );

  @override
  List<Object?> get props => [id, habitId, completedAt, note];
}

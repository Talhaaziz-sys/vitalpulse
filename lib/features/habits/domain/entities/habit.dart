import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';

/// Frequency at which a habit should be performed.
enum HabitFrequency {
  /// Habit should be done every day.
  daily,

  /// Habit should be done a set number of times each week.
  weekly,
}

/// Domain entity representing a habit tracked by the user.
final class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.goal,
    required this.color,
    required this.iconCodePoint,
    required this.createdAt,
  });

  /// Unique identifier (UUID).
  final String id;

  /// Display name of the habit.
  final String title;

  /// Optional description.
  final String description;

  /// How often this habit should be performed.
  final HabitFrequency frequency;

  /// Target number of completions per frequency period.
  final int goal;

  /// ARGB integer color for display purposes.
  final int color;

  /// Flutter icon code point (e.g., `Icons.fitness_center.codePoint`).
  final int iconCodePoint;

  /// When the habit was created.
  final DateTime createdAt;

  /// Returns the [Color] object for this habit's color value.
  Color get displayColor => Color(color);

  /// Returns the [IconData] for this habit's icon.
  IconData get displayIcon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  /// Returns a copy with the given fields replaced.
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitFrequency? frequency,
    int? goal,
    int? color,
    int? iconCodePoint,
    DateTime? createdAt,
  }) =>
      Habit(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        frequency: frequency ?? this.frequency,
        goal: goal ?? this.goal,
        color: color ?? this.color,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        frequency,
        goal,
        color,
        iconCodePoint,
        createdAt,
      ];

  /// Creates a new [Habit] with sensible defaults for testing/preview purposes.
  static Habit preview({
    String id = 'preview',
    String title = 'Morning Run',
    HabitFrequency frequency = HabitFrequency.daily,
  }) =>
      Habit(
        id: id,
        title: title,
        description: 'Start the day with a 30-minute run',
        frequency: frequency,
        goal: 1,
        color: AppColors.accentCyan.toARGB32(),
        iconCodePoint: Icons.directions_run.codePoint,
        createdAt: DateTime.now(),
      );
}

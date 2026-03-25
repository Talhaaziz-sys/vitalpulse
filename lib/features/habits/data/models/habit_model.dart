import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';

/// SQLite model for the [Habit] entity.
///
/// Handles serialization to/from database row maps.
final class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.frequency,
    required this.goal,
    required this.color,
    required this.icon,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String frequency;
  final int goal;
  final int color;
  final int icon;
  final String createdAt;

  static const _tableName = AppConstants.habitsTable;

  static String get tableName => _tableName;

  /// Creates a [HabitModel] from a SQLite row [map].
  factory HabitModel.fromMap(Map<String, dynamic> map) => HabitModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        frequency: map['frequency'] as String? ?? 'daily',
        goal: map['goal'] as int? ?? 1,
        color: map['color'] as int? ?? 0,
        icon: map['icon'] as int? ?? 0,
        createdAt: map['created_at'] as String,
      );

  /// Converts this model to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'frequency': frequency,
        'goal': goal,
        'color': color,
        'icon': icon,
        'created_at': createdAt,
      };

  /// Converts to a domain [Habit] entity.
  Habit toEntity() => Habit(
        id: id,
        title: title,
        description: description,
        frequency: frequency == 'weekly'
            ? HabitFrequency.weekly
            : HabitFrequency.daily,
        goal: goal,
        color: color,
        iconCodePoint: icon,
        createdAt: DateTime.parse(createdAt),
      );

  /// Creates a [HabitModel] from a domain [Habit] entity.
  factory HabitModel.fromEntity(Habit entity) => HabitModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        frequency: entity.frequency.name,
        goal: entity.goal,
        color: entity.color,
        icon: entity.iconCodePoint,
        createdAt: entity.createdAt.toIso8601String(),
      );
}

/// SQLite model for the [HabitLog] entity.
final class HabitLogModel {
  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.completedAt,
    required this.note,
  });

  final String id;
  final String habitId;
  final String completedAt;
  final String note;

  static const _tableName = AppConstants.habitLogsTable;
  static String get tableName => _tableName;

  /// Creates a [HabitLogModel] from a SQLite row [map].
  factory HabitLogModel.fromMap(Map<String, dynamic> map) => HabitLogModel(
        id: map['id'] as String,
        habitId: map['habit_id'] as String,
        completedAt: map['completed_at'] as String,
        note: map['note'] as String? ?? '',
      );

  /// Converts this model to a SQLite row map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'completed_at': completedAt,
        'note': note,
      };

  /// Converts to a domain [HabitLog] entity.
  HabitLog toEntity() => HabitLog(
        id: id,
        habitId: habitId,
        completedAt: DateTime.parse(completedAt),
        note: note,
      );

  /// Creates a [HabitLogModel] from a domain [HabitLog] entity.
  factory HabitLogModel.fromEntity(HabitLog entity) => HabitLogModel(
        id: entity.id,
        habitId: entity.habitId,
        completedAt: entity.completedAt.toIso8601String(),
        note: entity.note,
      );
}

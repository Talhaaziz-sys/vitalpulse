import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';

/// SQLite model for [Workout].
final class WorkoutModel {
  const WorkoutModel({
    required this.id,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.notes,
    required this.loggedAt,
  });

  final String id;
  final String exerciseName;
  final int sets;
  final int reps;
  final double weightKg;
  final String notes;
  final String loggedAt;

  static String get tableName => AppConstants.workoutsTable;

  factory WorkoutModel.fromMap(Map<String, dynamic> map) => WorkoutModel(
        id: map['id'] as String,
        exerciseName: map['exercise_name'] as String,
        sets: map['sets'] as int? ?? 0,
        reps: map['reps'] as int? ?? 0,
        weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0,
        notes: map['notes'] as String? ?? '',
        loggedAt: map['logged_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'exercise_name': exerciseName,
        'sets': sets,
        'reps': reps,
        'weight_kg': weightKg,
        'notes': notes,
        'logged_at': loggedAt,
      };

  Workout toEntity() => Workout(
        id: id,
        exerciseName: exerciseName,
        sets: sets,
        reps: reps,
        weightKg: weightKg,
        notes: notes,
        loggedAt: DateTime.parse(loggedAt),
      );

  factory WorkoutModel.fromEntity(Workout e) => WorkoutModel(
        id: e.id,
        exerciseName: e.exerciseName,
        sets: e.sets,
        reps: e.reps,
        weightKg: e.weightKg,
        notes: e.notes,
        loggedAt: e.loggedAt.toIso8601String(),
      );
}

/// SQLite model for [WeightEntry].
final class WeightEntryModel {
  const WeightEntryModel({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
    required this.note,
  });

  final String id;
  final double weightKg;
  final String loggedAt;
  final String note;

  static String get tableName => AppConstants.weightEntriesTable;

  factory WeightEntryModel.fromMap(Map<String, dynamic> map) =>
      WeightEntryModel(
        id: map['id'] as String,
        weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 0.0,
        loggedAt: map['logged_at'] as String,
        note: map['note'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'weight_kg': weightKg,
        'logged_at': loggedAt,
        'note': note,
      };

  WeightEntry toEntity() => WeightEntry(
        id: id,
        weightKg: weightKg,
        loggedAt: DateTime.parse(loggedAt),
        note: note,
      );

  factory WeightEntryModel.fromEntity(WeightEntry e) => WeightEntryModel(
        id: e.id,
        weightKg: e.weightKg,
        loggedAt: e.loggedAt.toIso8601String(),
        note: e.note,
      );
}

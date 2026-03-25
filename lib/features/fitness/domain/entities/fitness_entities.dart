import 'package:equatable/equatable.dart';

/// Domain entity representing a single workout log entry.
final class Workout extends Equatable {
  const Workout({
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
  final DateTime loggedAt;

  /// Total volume = sets × reps × weight.
  double get volume => sets * reps * weightKg;

  Workout copyWith({
    String? id,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weightKg,
    String? notes,
    DateTime? loggedAt,
  }) =>
      Workout(
        id: id ?? this.id,
        exerciseName: exerciseName ?? this.exerciseName,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        weightKg: weightKg ?? this.weightKg,
        notes: notes ?? this.notes,
        loggedAt: loggedAt ?? this.loggedAt,
      );

  @override
  List<Object?> get props =>
      [id, exerciseName, sets, reps, weightKg, notes, loggedAt];
}

/// Domain entity representing a body weight entry.
final class WeightEntry extends Equatable {
  const WeightEntry({
    required this.id,
    required this.weightKg,
    required this.loggedAt,
    this.note = '',
  });

  final String id;
  final double weightKg;
  final DateTime loggedAt;
  final String note;

  WeightEntry copyWith({
    String? id,
    double? weightKg,
    DateTime? loggedAt,
    String? note,
  }) =>
      WeightEntry(
        id: id ?? this.id,
        weightKg: weightKg ?? this.weightKg,
        loggedAt: loggedAt ?? this.loggedAt,
        note: note ?? this.note,
      );

  @override
  List<Object?> get props => [id, weightKg, loggedAt, note];
}

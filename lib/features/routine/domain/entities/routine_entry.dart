import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Domain entity representing a single routine entry in the scheduler.
final class RoutineEntry extends Equatable {
  const RoutineEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.color,
    required this.createdAt,
  });

  /// Unique identifier (UUID).
  final String id;

  /// Display name of the routine.
  final String title;

  /// Optional description.
  final String description;

  /// Start time (hour and minute).
  final TimeOfDay startTime;

  /// End time (hour and minute).
  final TimeOfDay endTime;

  /// List of weekday indices (1 = Monday … 7 = Sunday) this routine repeats on.
  final List<int> daysOfWeek;

  /// ARGB integer color.
  final int color;

  /// When the routine was created.
  final DateTime createdAt;

  /// Returns the [Color] object for this entry.
  Color get displayColor => Color(color);

  /// Returns the duration of this routine entry.
  Duration get duration {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final diff = endMinutes - startMinutes;
    return Duration(minutes: diff < 0 ? diff + 24 * 60 : diff);
  }

  /// Returns a copy with the given fields replaced.
  RoutineEntry copyWith({
    String? id,
    String? title,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? daysOfWeek,
    int? color,
    DateTime? createdAt,
  }) =>
      RoutineEntry(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        daysOfWeek,
        color,
        createdAt,
      ];
}

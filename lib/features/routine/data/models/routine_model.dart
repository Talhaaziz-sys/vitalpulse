import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/features/routine/domain/entities/routine_entry.dart';

/// SQLite model for [RoutineEntry].
final class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.color,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String startTime; // 'HH:mm'
  final String endTime;   // 'HH:mm'
  final String daysOfWeek; // JSON array '[1,2,3]'
  final int color;
  final String createdAt;

  static String get tableName => AppConstants.routinesTable;

  factory RoutineModel.fromMap(Map<String, dynamic> map) => RoutineModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        startTime: map['start_time'] as String,
        endTime: map['end_time'] as String,
        daysOfWeek: map['days_of_week'] as String? ?? '[]',
        color: map['color'] as int? ?? 0,
        createdAt: map['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'start_time': startTime,
        'end_time': endTime,
        'days_of_week': daysOfWeek,
        'color': color,
        'created_at': createdAt,
      };

  RoutineEntry toEntity() {
    final parts = startTime.split(':');
    final endParts = endTime.split(':');
    final days = (jsonDecode(daysOfWeek) as List<dynamic>)
        .map((e) => e as int)
        .toList();

    return RoutineEntry(
      id: id,
      title: title,
      description: description,
      startTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      daysOfWeek: days,
      color: color,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory RoutineModel.fromEntity(RoutineEntry entry) => RoutineModel(
        id: entry.id,
        title: entry.title,
        description: entry.description,
        startTime:
            '${entry.startTime.hour.toString().padLeft(2, '0')}:${entry.startTime.minute.toString().padLeft(2, '0')}',
        endTime:
            '${entry.endTime.hour.toString().padLeft(2, '0')}:${entry.endTime.minute.toString().padLeft(2, '0')}',
        daysOfWeek: jsonEncode(entry.daysOfWeek),
        color: entry.color,
        createdAt: entry.createdAt.toIso8601String(),
      );
}

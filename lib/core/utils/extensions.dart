import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date/time utility functions for VitalPulse.
extension DateTimeExtensions on DateTime {
  /// Returns the date portion only (no time component).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns `true` if this date is the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns a human-readable greeting based on the current hour.
  String get greeting {
    final hour = this.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Formats the date as `Monday, March 25`.
  String get fullDate => DateFormat('EEEE, MMMM d').format(this);

  /// Formats the date as `Mar 25, 2026`.
  String get shortDate => DateFormat('MMM d, y').format(this);

  /// Formats the time as `09:30 AM`.
  String get formattedTime => DateFormat('hh:mm a').format(this);

  /// Formats the date as ISO 8601 date string `2026-03-25`.
  String get isoDate => DateFormat('yyyy-MM-dd').format(this);

  /// Returns the first day of the current week (Monday).
  DateTime get startOfWeek {
    final daysFromMonday = weekday - DateTime.monday;
    return dateOnly.subtract(Duration(days: daysFromMonday));
  }

  /// Returns the last day of the current week (Sunday).
  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6));
}

/// Color utility for converting between [Color] and integer.
extension ColorExtensions on Color {
  /// Converts a [Color] to its ARGB integer representation.
  int get colorValue => toARGB32();
}

extension ColorFromInt on int {
  /// Creates a [Color] from an ARGB integer.
  Color get toColor => Color(this);
}

extension StringFormatExtensions on String {
  /// Capitalizes the first letter of the string.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Parses an ISO 8601 date string to [DateTime].
  DateTime get toDateTime => DateTime.parse(this);
}

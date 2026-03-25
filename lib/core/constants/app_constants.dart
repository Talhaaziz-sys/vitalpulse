/// Application-wide constants for VitalPulse.
library;

/// Color constants, spacing, and other app-wide values.
abstract final class AppConstants {
  // App Identity
  static const String appName = 'VitalPulse';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'vitalpulse.db';
  static const int databaseVersion = 1;

  // Table names
  static const String routinesTable = 'routines';
  static const String habitsTable = 'habits';
  static const String habitLogsTable = 'habit_logs';
  static const String workoutsTable = 'workouts';
  static const String weightEntriesTable = 'weight_entries';

  // Shared preferences keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';

  // UI constants
  static const double cardBorderRadius = 20.0;
  static const double buttonBorderRadius = 12.0;
  static const double blurSigma = 15.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Health permissions
  static const int healthSyncDays = 30;
}

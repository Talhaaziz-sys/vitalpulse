import 'package:flutter/material.dart';

/// VitalPulse brand color palette.
///
/// Dark glassmorphism theme with electric cyan and neon purple accents.
abstract final class AppColors {
  // Background gradients
  static const Color backgroundStart = Color(0xFF0D0D2B);
  static const Color backgroundEnd = Color(0xFF1A1A3E);
  static const Color backgroundMid = Color(0xFF12122A);

  // Accent colors
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentPurple = Color(0xFF8A2BE2);
  static const Color accentPink = Color(0xFFFF2D78);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentYellow = Color(0xFFFFD740);

  // Glass card colors
  static const Color glassFill = Color(0x14FFFFFF); // 8% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassHover = Color(0x1FFFFFFF); // 12% white

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textHint = Color(0x66FFFFFF); // 40% white

  // Status colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD740);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF40C4FF);

  // Habit/feature specific colors
  static const List<Color> habitColors = [
    Color(0xFF00D4FF),
    Color(0xFF8A2BE2),
    Color(0xFF00E676),
    Color(0xFFFF6D00),
    Color(0xFFFF2D78),
    Color(0xFFFFD740),
    Color(0xFF40C4FF),
    Color(0xFF7C4DFF),
  ];
}

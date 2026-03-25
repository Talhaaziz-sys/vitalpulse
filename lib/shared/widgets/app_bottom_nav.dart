import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';

/// Frosted-glass bottom navigation bar used across VitalPulse.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_rounded),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.schedule_rounded),
      label: 'Routine',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.track_changes_rounded),
      label: 'Habits',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.fitness_center_rounded),
      label: 'Fitness',
    ),
  ];

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0x1AFFFFFF),
              border: Border(
                top: BorderSide(color: AppColors.glassBorder, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.accentCyan,
              unselectedItemColor: AppColors.textHint,
              selectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              items: _items,
            ),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/features/dashboard/dashboard_screen.dart';
import 'package:vitalpulse/features/routine/presentation/screens/routine_screen.dart';
import 'package:vitalpulse/features/habits/presentation/screens/habits_screen.dart';
import 'package:vitalpulse/features/fitness/presentation/screens/fitness_screen.dart';
import 'package:vitalpulse/shared/widgets/app_bottom_nav.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';

/// Current navigation tab index.
final _tabIndexProvider = StateProvider<int>((_) => 0);

/// Root shell widget that contains the bottom navigation bar
/// and hosts all top-level screens.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    DashboardScreen(),
    RoutineScreen(),
    HabitsScreen(),
    FitnessScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(_tabIndexProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundStart,
            AppColors.backgroundMid,
            AppColors.backgroundEnd,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: currentIndex,
          onTap: (index) =>
              ref.read(_tabIndexProvider.notifier).state = index,
        ),
      ),
    );
  }
}

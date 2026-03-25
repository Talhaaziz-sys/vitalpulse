import 'package:flutter/material.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit_with_stats.dart';
import 'package:vitalpulse/shared/widgets/glass_card.dart';

/// A card that displays a single [HabitWithStats].
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.stats,
    required this.onToggle,
    this.onLongPress,
  });

  final HabitWithStats stats;
  final VoidCallback onToggle;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final habit = stats.habit;
    final accentColor = habit.displayColor;

    return GlassCardAccent(
      accentColor: accentColor,
      onTap: onToggle,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                habit.displayIcon,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Title & meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatChip(
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.accentOrange,
                        label: '${stats.currentStreak}d',
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.accentYellow,
                        label: '${stats.longestStreak}d best',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Completion toggle
            _CompletionButton(
              completed: stats.completedToday,
              color: accentColor,
              onTap: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
}

class _CompletionButton extends StatelessWidget {
  const _CompletionButton({
    required this.completed,
    required this.color,
    required this.onTap,
  });

  final bool completed;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: completed ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: completed ? color : AppColors.glassBorder,
            width: 2,
          ),
        ),
        child: completed
            ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              )
            : const SizedBox.shrink(),
      );
}

import 'package:flutter/material.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';
import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';
import 'package:vitalpulse/shared/widgets/glass_card.dart';

/// Card widget for a logged workout set.
class WorkoutLogCard extends StatelessWidget {
  const WorkoutLogCard({
    super.key,
    required this.workout,
    this.onDelete,
  });

  final Workout workout;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => GlassCardAccent(
        accentColor: AppColors.accentPurple,
        child: Row(
          children: [
            // Exercise icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.accentPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.exerciseName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MetricChip(
                        label: '${workout.sets} sets',
                        color: AppColors.accentCyan,
                      ),
                      const SizedBox(width: 6),
                      _MetricChip(
                        label: '${workout.reps} reps',
                        color: AppColors.accentGreen,
                      ),
                      const SizedBox(width: 6),
                      _MetricChip(
                        label: '${workout.weightKg}kg',
                        color: AppColors.accentOrange,
                      ),
                    ],
                  ),
                  if (workout.notes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      workout.notes,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textHint,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
          ],
        ),
      );
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

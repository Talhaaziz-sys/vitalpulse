import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/presentation/providers/habit_providers.dart';
import 'package:vitalpulse/features/habits/presentation/widgets/habit_card.dart';
import 'package:vitalpulse/shared/widgets/glass_card.dart';

/// Main screen for the Habits feature.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            onPressed: () => _showAddHabitSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Habit',
          ),
        ],
      ),
      body: habitsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading habits:\n$err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (habitsWithStats) {
          if (habitsWithStats.isEmpty) {
            return _EmptyState(
              onAddHabit: () => _showAddHabitSheet(context, ref),
            );
          }

          return RefreshIndicator(
            color: AppColors.accentCyan,
            backgroundColor: AppColors.backgroundMid,
            onRefresh: () => ref.refresh(habitNotifierProvider.future),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Summary banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: _SummaryBanner(
                      completed: habitsWithStats
                          .where((h) => h.completedToday)
                          .length,
                      total: habitsWithStats.length,
                    ),
                  ),
                ),

                // Habit list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList.separated(
                    itemCount: habitsWithStats.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final stats = habitsWithStats[index];
                      return HabitCard(
                        stats: stats,
                        onToggle: () => ref
                            .read(habitNotifierProvider.notifier)
                            .toggleCompletion(stats.habit),
                        onLongPress: () =>
                            _confirmDelete(context, ref, stats.habit),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitSheet(context, ref),
        tooltip: 'Add Habit',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddHabitSheet(ref: ref),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Delete "${habit.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref
          .read(habitNotifierProvider.notifier)
          .deleteHabit(habit.id);
    }
  }
}

// ── Summary Banner ────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Progress",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppColors.accentCyan,
              backgroundColor: AppColors.glassFill,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddHabit});

  final VoidCallback onAddHabit;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding:
              const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.track_changes_rounded,
                size: 72,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              const Text(
                'No habits yet',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start building atomic habits.\nSmall wins, big results.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAddHabit,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Your First Habit'),
              ),
            ],
          ),
        ),
      );
}

// ── Add Habit Bottom Sheet ────────────────────────────────────────────────────

class _AddHabitSheet extends StatefulWidget {
  const _AddHabitSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;
  int _goal = 1;
  Color _selectedColor = AppColors.accentCyan;
  int _selectedIconCodePoint = Icons.star_rounded.codePoint;

  static const _availableIcons = [
    Icons.directions_run_rounded,
    Icons.fitness_center_rounded,
    Icons.self_improvement_rounded,
    Icons.local_drink_rounded,
    Icons.book_rounded,
    Icons.bedtime_rounded,
    Icons.music_note_rounded,
    Icons.code_rounded,
    Icons.star_rounded,
    Icons.favorite_rounded,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Habit',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Raleway',
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title field
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Habit name *',
                  prefixIcon: Icon(Icons.edit_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a habit name' : null,
              ),
              const SizedBox(height: 12),

              // Description field
              TextFormField(
                controller: _descController,
                style: const TextStyle(color: AppColors.textPrimary),
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Frequency picker
              const Text(
                'Frequency',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: HabitFrequency.values.map((freq) {
                  final selected = _frequency == freq;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        freq.name.capitalized,
                        style: TextStyle(
                          color: selected
                              ? AppColors.backgroundStart
                              : AppColors.textSecondary,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.accentCyan,
                      onSelected: (_) =>
                          setState(() => _frequency = freq),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Goal
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daily goal',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            setState(() => _goal = (_goal - 1).clamp(1, 20)),
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: AppColors.textHint,
                        ),
                        iconSize: 20,
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_goal',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _goal = (_goal + 1).clamp(1, 20)),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.accentCyan,
                        ),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Icon picker
              const Text(
                'Icon',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((iconData) {
                  final selected =
                      _selectedIconCodePoint == iconData.codePoint;
                  return GestureDetector(
                    onTap: () => setState(
                      () => _selectedIconCodePoint = iconData.codePoint,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected
                            ? _selectedColor.withValues(alpha: 0.2)
                            : AppColors.glassFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? _selectedColor
                              : AppColors.glassBorder,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        iconData,
                        color: selected ? _selectedColor : AppColors.textHint,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Color picker
              const Text(
                'Color',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppColors.habitColors.map((color) {
                  final selected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  child: const Text('Save Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.ref.read(habitNotifierProvider.notifier).addHabit(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          frequency: _frequency,
          goal: _goal,
          color: _selectedColor.toARGB32(),
          iconCodePoint: _selectedIconCodePoint,
        );

    if (mounted) Navigator.pop(context);
  }
}

// ignore: prefer_expression_function_bodies
extension on String {
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

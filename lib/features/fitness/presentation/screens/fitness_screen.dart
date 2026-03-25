import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/features/fitness/domain/entities/fitness_entities.dart';
import 'package:vitalpulse/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:vitalpulse/features/fitness/presentation/widgets/weight_chart.dart';
import 'package:vitalpulse/features/fitness/presentation/widgets/workout_log_card.dart';

/// Main screen for the Fitness / Bodybuilding feature.
class FitnessScreen extends ConsumerStatefulWidget {
  const FitnessScreen({super.key});

  @override
  ConsumerState<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends ConsumerState<FitnessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Fitness'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accentCyan,
            labelColor: AppColors.accentCyan,
            unselectedLabelColor: AppColors.textHint,
            tabs: const [
              Tab(icon: Icon(Icons.fitness_center_rounded), text: 'Workouts'),
              Tab(icon: Icon(Icons.monitor_weight_rounded), text: 'Weight'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _WorkoutsTab(),
            _WeightTab(),
          ],
        ),
      );
}

// ── Workouts Tab ──────────────────────────────────────────────────────────────

class _WorkoutsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogWorkoutSheet(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
      body: workoutsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (workouts) {
          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fitness_center_rounded,
                    size: 72,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No workouts logged',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Raleway',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your sets, reps, and weights.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showLogWorkoutSheet(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Log Workout'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return WorkoutLogCard(
                workout: workout,
                onDelete: () => ref
                    .read(workoutNotifierProvider.notifier)
                    .deleteWorkout(workout.id),
              );
            },
          );
        },
      ),
    );
  }

  void _showLogWorkoutSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogWorkoutSheet(ref: ref),
    );
  }
}

// ── Weight Tab ────────────────────────────────────────────────────────────────

class _WeightTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightAsync = ref.watch(weightNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogWeightSheet(context, ref),
        heroTag: 'weight_fab',
        child: const Icon(Icons.add_rounded),
      ),
      body: weightAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (entries) => CustomScrollView(
          slivers: [
            // Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: WeightChart(entries: entries),
              ),
            ),

            // Recent entries
            if (entries.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    'History',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    // Show in reverse chronological order
                    final entry = entries[entries.length - 1 - index];
                    return _WeightEntryTile(
                      entry: entry,
                      onDelete: () => ref
                          .read(weightNotifierProvider.notifier)
                          .deleteEntry(entry.id),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLogWeightSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogWeightSheet(ref: ref),
    );
  }
}

class _WeightEntryTile extends StatelessWidget {
  const _WeightEntryTile({required this.entry, this.onDelete});

  final WeightEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: AppColors.glassFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        leading: const Icon(
          Icons.monitor_weight_rounded,
          color: AppColors.accentCyan,
        ),
        title: Text(
          '${entry.weightKg} kg',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          entry.loggedAt.toString().substring(0, 10),
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 12,
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.textHint,
                  size: 18,
                ),
              )
            : null,
      );
}

// ── Log Workout Sheet ─────────────────────────────────────────────────────────

class _LogWorkoutSheet extends StatefulWidget {
  const _LogWorkoutSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_LogWorkoutSheet> createState() => _LogWorkoutSheetState();
}

class _LogWorkoutSheetState extends State<_LogWorkoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _sets = 3;
  int _reps = 10;
  double _weight = 20;

  @override
  void dispose() {
    _exerciseCtrl.dispose();
    _notesCtrl.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Workout',
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

              TextFormField(
                controller: _exerciseCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Exercise name *',
                  prefixIcon: Icon(Icons.fitness_center_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter exercise name' : null,
              ),
              const SizedBox(height: 16),

              // Sets / Reps / Weight row
              Row(
                children: [
                  Expanded(
                    child: _NumberStepper(
                      label: 'Sets',
                      value: _sets,
                      min: 1,
                      max: 20,
                      onChanged: (v) => setState(() => _sets = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _NumberStepper(
                      label: 'Reps',
                      value: _reps,
                      min: 1,
                      max: 100,
                      onChanged: (v) => setState(() => _reps = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DecimalStepper(
                      label: 'kg',
                      value: _weight,
                      step: 2.5,
                      onChanged: (v) => setState(() => _weight = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Log Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.ref.read(workoutNotifierProvider.notifier).logWorkout(
          exerciseName: _exerciseCtrl.text.trim(),
          sets: _sets,
          reps: _reps,
          weightKg: _weight,
          notes: _notesCtrl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }
}

// ── Log Weight Sheet ──────────────────────────────────────────────────────────

class _LogWeightSheet extends StatefulWidget {
  const _LogWeightSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<_LogWeightSheet> {
  final _weightCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _noteCtrl.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Weight',
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

              TextFormField(
                controller: _weightCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg) *',
                  prefixIcon: Icon(Icons.monitor_weight_rounded),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your weight';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _noteCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.ref.read(weightNotifierProvider.notifier).logWeight(
          weightKg: double.parse(_weightCtrl.text.trim()),
          note: _noteCtrl.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }
}

// ── Reusable steppers ─────────────────────────────────────────────────────────

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onChanged((value - 1).clamp(min, max)),
                  child: const Icon(
                    Icons.remove_circle_outline,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onChanged((value + 1).clamp(min, max)),
                  child: const Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: AppColors.accentCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _DecimalStepper extends StatelessWidget {
  const _DecimalStepper({
    required this.label,
    required this.value,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    final newVal = (value - step).clamp(0.0, 999.0);
                    onChanged(newVal);
                  },
                  child: const Icon(
                    Icons.remove_circle_outline,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    final newVal = (value + step).clamp(0.0, 999.0);
                    onChanged(newVal);
                  },
                  child: const Icon(
                    Icons.add_circle_outline,
                    size: 18,
                    color: AppColors.accentCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

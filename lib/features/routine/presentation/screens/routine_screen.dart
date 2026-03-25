import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalpulse/core/theme/app_colors.dart';
import 'package:vitalpulse/core/constants/app_constants.dart';
import 'package:vitalpulse/features/routine/presentation/providers/routine_providers.dart';
import 'package:vitalpulse/features/routine/presentation/widgets/routine_tile.dart';
import 'package:vitalpulse/shared/widgets/glass_card.dart';

/// Main screen for the Routine feature.
class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final routinesAsync = ref.watch(routineNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Routine'),
        actions: [
          IconButton(
            onPressed: () => _showAddRoutineSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day picker
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _DayPicker(
              selectedDay: selectedDay,
              onDaySelected: (day) =>
                  ref.read(selectedDayProvider.notifier).state = day,
            ),
          ),

          // Timeline list
          Expanded(
            child: routinesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accentCyan),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return _EmptyRoutine(
                    dayLabel: _weekDays[selectedDay - 1],
                    onAdd: () => _showAddRoutineSheet(context, ref),
                  );
                }

                return ListView.separated(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return RoutineTile(
                      entry: entry,
                      onDelete: () => ref
                          .read(routineNotifierProvider.notifier)
                          .deleteRoutine(entry.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRoutineSheet(context, ref),
        tooltip: 'Add Routine',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddRoutineSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRoutineSheet(ref: ref),
    );
  }
}

// ── Day Picker ────────────────────────────────────────────────────────────────

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.selectedDay,
    required this.onDaySelected,
  });

  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _days.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final dayIndex = index + 1; // 1–7
            final isSelected = selectedDay == dayIndex;

            return GestureDetector(
              onTap: () => onDaySelected(dayIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentCyan
                      : AppColors.glassFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentCyan
                        : AppColors.glassBorder,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _days[index],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.backgroundStart
                            : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyRoutine extends StatelessWidget {
  const _EmptyRoutine({required this.dayLabel, required this.onAdd});

  final String dayLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 72,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'Nothing on $dayLabel',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Raleway',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Design your perfect day.\nAdd blocks to your schedule.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Routine Block'),
              ),
            ],
          ),
        ),
      );
}

// ── Add Routine Bottom Sheet ──────────────────────────────────────────────────

class _AddRoutineSheet extends StatefulWidget {
  const _AddRoutineSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<_AddRoutineSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);
  final Set<int> _selectedDays = {};
  Color _selectedColor = AppColors.accentCyan;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _selectedDays.add(widget.ref.read(selectedDayProvider));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
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
                    'Add Routine Block',
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
                controller: _titleCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _TimePicker(
                      label: 'Start',
                      time: _startTime,
                      onPicked: (t) => setState(() => _startTime = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePicker(
                      label: 'End',
                      time: _endTime,
                      onPicked: (t) => setState(() => _endTime = t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Days picker
              const Text(
                'Repeat on',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (i) {
                  final day = i + 1;
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        color: selected
                            ? AppColors.backgroundStart
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    selected: selected,
                    selectedColor: _selectedColor,
                    onSelected: (_) => setState(() {
                      if (selected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    }),
                  );
                }),
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
                  final sel = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    await widget.ref.read(routineNotifierProvider.notifier).addRoutine(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          startTime: _startTime,
          endTime: _endTime,
          daysOfWeek: _selectedDays.toList()..sort(),
          color: _selectedColor.toARGB32(),
        );

    if (mounted) Navigator.pop(context);
  }
}

class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.label,
    required this.time,
    required this.onPicked,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
          );
          if (picked != null) onPicked(picked);
        },
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 16,
              color: AppColors.accentCyan,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time.format(context),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

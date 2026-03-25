import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';

/// Use case that persists a new habit.
final class AddHabitUseCase {
  const AddHabitUseCase({required this.repository});

  final HabitRepository repository;

  Future<void> call(Habit habit) => repository.addHabit(habit);
}

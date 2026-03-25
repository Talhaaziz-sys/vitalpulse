import 'package:vitalpulse/features/habits/domain/entities/habit.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';

/// Use case that retrieves all habits from the repository.
final class GetHabitsUseCase {
  const GetHabitsUseCase({required this.repository});

  final HabitRepository repository;

  Future<List<Habit>> call() => repository.getHabits();
}

import 'package:vitalpulse/features/habits/domain/entities/habit_log.dart';
import 'package:vitalpulse/features/habits/domain/repositories/habit_repository.dart';

/// Use case that logs a habit completion.
final class CompleteHabitUseCase {
  const CompleteHabitUseCase({required this.repository});

  final HabitRepository repository;

  Future<void> call(HabitLog log) => repository.addHabitLog(log);
}

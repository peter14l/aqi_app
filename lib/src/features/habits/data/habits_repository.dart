import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/habit_model.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<ExposureData> calculateExposure(
    List<Habit> habits,
    double currentPm25,
  );
}

class MockHabitsRepository implements HabitsRepository {
  final List<Habit> _habits = [
    Habit(
      id: '1',
      name: 'Morning Commute',
      durationMinutes: 45,
      isOutdoor: true,
      timeOfDay: const TimeOfDay(hour: 8, minute: 30),
    ),
    Habit(
      id: '2',
      name: 'Lunch Walk',
      durationMinutes: 20,
      isOutdoor: true,
      timeOfDay: const TimeOfDay(hour: 13, minute: 0),
    ),
  ];

  @override
  Future<List<Habit>> getHabits() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _habits;
  }

  @override
  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
  }

  @override
  Future<ExposureData> calculateExposure(
    List<Habit> habits,
    double currentPm25,
  ) async {
    // Simple mock calculation: (Duration * PM2.5) / 60
    double totalExposure = 0;
    for (var habit in habits) {
      if (habit.isOutdoor) {
        totalExposure += (habit.durationMinutes * currentPm25) / 60;
      }
    }

    String recommendation = "Low exposure. Enjoy your day!";
    if (totalExposure > 50) {
      recommendation = "Consider wearing a mask during commute.";
    }
    if (totalExposure > 100) {
      recommendation = "High exposure! Limit outdoor activities.";
    }

    return ExposureData(
      dailyExposure: totalExposure,
      recommendation: recommendation,
    );
  }
}

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return MockHabitsRepository();
});

final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  return ref.watch(habitsRepositoryProvider).getHabits();
});

final exposureProvider = FutureProvider.family<ExposureData, double>((
  ref,
  currentPm25,
) async {
  final habits = await ref.watch(habitsProvider.future);
  return ref
      .watch(habitsRepositoryProvider)
      .calculateExposure(habits, currentPm25);
});

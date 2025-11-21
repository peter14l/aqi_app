import '../domain/habit_model.dart';

/// Demo habits for demonstrations
class DemoHabits {
  static final List<Habit> habits = [
    Habit(
      id: 'demo_1',
      name: 'Morning Run',
      durationMinutes: 30,
      isOutdoor: true,
      timeOfDay: const TimeOfDay(hour: 7, minute: 0),
    ),
    Habit(
      id: 'demo_2',
      name: 'Commute to Work',
      durationMinutes: 45,
      isOutdoor: true,
      timeOfDay: const TimeOfDay(hour: 8, minute: 30),
    ),
    Habit(
      id: 'demo_3',
      name: 'Office Work',
      durationMinutes: 480,
      isOutdoor: false,
      timeOfDay: const TimeOfDay(hour: 9, minute: 0),
    ),
    Habit(
      id: 'demo_4',
      name: 'Evening Walk',
      durationMinutes: 20,
      isOutdoor: true,
      timeOfDay: const TimeOfDay(hour: 18, minute: 0),
    ),
    Habit(
      id: 'demo_5',
      name: 'Gym Workout',
      durationMinutes: 60,
      isOutdoor: false,
      timeOfDay: const TimeOfDay(hour: 19, minute: 0),
    ),
  ];

  static List<Habit> get demoHabits => habits;
}

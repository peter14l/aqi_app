class Habit {
  final String id;
  final String name; // e.g., "Morning Commute", "Evening Jog"
  final int durationMinutes;
  final bool isOutdoor;
  final TimeOfDay timeOfDay; // Approximate time

  Habit({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.isOutdoor,
    required this.timeOfDay,
  });
}

class ExposureData {
  final double dailyExposure; // Accumulated PM2.5 exposure
  final String recommendation; // e.g., "Wear a mask", "Avoid outdoor"

  ExposureData({required this.dailyExposure, required this.recommendation});
}

// Helper for TimeOfDay serialization if needed later
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

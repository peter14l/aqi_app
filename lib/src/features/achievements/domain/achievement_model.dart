import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_model.freezed.dart';
part 'achievement_model.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    required String id,
    required String title,
    required String description,
    required String icon,
    required int requiredCount,
    @Default(0) int currentCount,
    @Default(false) bool isUnlocked,
    DateTime? unlockedAt,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Predefined achievements
class Achievements {
  static final List<Achievement> all = [
    const Achievement(
      id: 'first_query',
      title: 'First Steps',
      description: 'Ask your first question to the AI assistant',
      icon: '🎯',
      requiredCount: 1,
    ),
    const Achievement(
      id: 'curious_mind',
      title: 'Curious Mind',
      description: 'Ask 10 questions to the AI assistant',
      icon: '🧠',
      requiredCount: 10,
    ),
    const Achievement(
      id: 'air_quality_expert',
      title: 'Air Quality Expert',
      description: 'Ask 50 questions to the AI assistant',
      icon: '🎓',
      requiredCount: 50,
    ),
    const Achievement(
      id: 'week_streak',
      title: 'Week Warrior',
      description: 'Check AQI for 7 consecutive days',
      icon: '🔥',
      requiredCount: 7,
    ),
    const Achievement(
      id: 'month_streak',
      title: 'Monthly Master',
      description: 'Check AQI for 30 consecutive days',
      icon: '⭐',
      requiredCount: 30,
    ),
    const Achievement(
      id: 'first_simulation',
      title: 'Future Thinker',
      description: 'Run your first what-if simulation',
      icon: '🔮',
      requiredCount: 1,
    ),
    const Achievement(
      id: 'route_optimizer',
      title: 'Route Optimizer',
      description: 'Check route exposure 5 times',
      icon: '🗺️',
      requiredCount: 5,
    ),
    const Achievement(
      id: 'health_conscious',
      title: 'Health Conscious',
      description: 'Track habits for 7 days',
      icon: '💪',
      requiredCount: 7,
    ),
    const Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Check AQI before 8 AM',
      icon: '🌅',
      requiredCount: 1,
    ),
    const Achievement(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Check AQI after 10 PM',
      icon: '🌙',
      requiredCount: 1,
    ),
  ];
}

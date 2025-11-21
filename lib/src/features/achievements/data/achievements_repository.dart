import 'package:hive/hive.dart';
import '../domain/achievement_model.dart';

/// Repository for managing achievements
class AchievementsRepository {
  static const String _boxName = 'achievements';
  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// Get all achievements with current progress
  Future<List<Achievement>> getAllAchievements() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<Map>(_boxName);
    } else {
      _box = Hive.box<Map>(_boxName);
    }

    final savedData =
        _box.get('achievements', defaultValue: <String, dynamic>{})
            as Map<dynamic, dynamic>;

    return Achievements.all.map((achievement) {
      final saved = savedData[achievement.id] as Map<dynamic, dynamic>?;
      if (saved != null) {
        return achievement.copyWith(
          currentCount: saved['currentCount'] as int? ?? 0,
          isUnlocked: saved['isUnlocked'] as bool? ?? false,
          unlockedAt:
              saved['unlockedAt'] != null
                  ? DateTime.parse(saved['unlockedAt'] as String)
                  : null,
        );
      }
      return achievement;
    }).toList();
  }

  /// Update achievement progress
  Future<Achievement?> updateProgress(
    String achievementId,
    int increment,
  ) async {
    final achievements = await getAllAchievements();
    final index = achievements.indexWhere((a) => a.id == achievementId);

    if (index == -1) return null;

    final achievement = achievements[index];
    if (achievement.isUnlocked) return null;

    final newCount = achievement.currentCount + increment;
    final isNowUnlocked = newCount >= achievement.requiredCount;

    final updated = achievement.copyWith(
      currentCount: newCount,
      isUnlocked: isNowUnlocked,
      unlockedAt: isNowUnlocked ? DateTime.now() : null,
    );

    await _saveAchievement(updated);

    return isNowUnlocked ? updated : null;
  }

  Future<void> _saveAchievement(Achievement achievement) async {
    final savedData =
        _box.get('achievements', defaultValue: <String, dynamic>{})
            as Map<dynamic, dynamic>;

    savedData[achievement.id] = {
      'currentCount': achievement.currentCount,
      'isUnlocked': achievement.isUnlocked,
      'unlockedAt': achievement.unlockedAt?.toIso8601String(),
    };

    await _box.put('achievements', savedData);
  }

  /// Get unlocked achievements count
  Future<int> getUnlockedCount() async {
    final achievements = await getAllAchievements();
    return achievements.where((a) => a.isUnlocked).length;
  }

  /// Reset all achievements (for testing)
  Future<void> resetAll() async {
    await _box.delete('achievements');
  }
}

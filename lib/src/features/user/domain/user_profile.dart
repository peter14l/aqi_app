import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final int? age;

  @HiveField(3)
  final String city;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final bool hasRespiratoryIssues;

  @HiveField(7)
  final bool hasHeartCondition;

  @HiveField(8)
  final bool isPregnant;

  @HiveField(9)
  final List<String> dailyRoutes;

  @HiveField(10)
  final Map<String, dynamic> preferences;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    this.name,
    this.age,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.hasRespiratoryIssues = false,
    this.hasHeartCondition = false,
    this.isPregnant = false,
    this.dailyRoutes = const [],
    this.preferences = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  UserProfile copyWith({
    String? userId,
    String? name,
    int? age,
    String? city,
    double? latitude,
    double? longitude,
    bool? hasRespiratoryIssues,
    bool? hasHeartCondition,
    bool? isPregnant,
    List<String>? dailyRoutes,
    Map<String, dynamic>? preferences,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      hasRespiratoryIssues: hasRespiratoryIssues ?? this.hasRespiratoryIssues,
      hasHeartCondition: hasHeartCondition ?? this.hasHeartCondition,
      isPregnant: isPregnant ?? this.isPregnant,
      dailyRoutes: dailyRoutes ?? this.dailyRoutes,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'hasRespiratoryIssues': hasRespiratoryIssues,
      'hasHeartCondition': hasHeartCondition,
      'isPregnant': isPregnant,
      'dailyRoutes': dailyRoutes,
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/user/domain/user_profile.dart';
import '../agents/agent_base.dart';
import '../services/agent_logger.dart';

/// Memory Agent - Manages long-term user preferences and behavioral patterns
class MemoryAgent extends AgentBase {
  static const String _userProfileBoxName = 'user_profiles';
  static const String _habitsBoxName = 'user_habits';
  static const String _queriesBoxName = 'user_queries';

  final AgentLogger _agentLogger = AgentLogger();

  Box<UserProfile>? _userProfileBox;
  Box<Map>? _habitsBox;
  Box<Map>? _queriesBox;

  MemoryAgent() : super(name: 'MemoryAgent');

  /// Initialize Hive boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserProfileAdapter());
      }

      // Open boxes
      _userProfileBox = await Hive.openBox<UserProfile>(_userProfileBoxName);
      _habitsBox = await Hive.openBox<Map>(_habitsBoxName);
      _queriesBox = await Hive.openBox<Map>(_queriesBoxName);

      logInfo('Memory Agent initialized successfully');
    } catch (e, stackTrace) {
      logError('Failed to initialize Memory Agent', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      final action = input['action'] as String?;
      if (action == null) {
        throw ArgumentError('Action is required');
      }

      Map<String, dynamic> result;

      switch (action) {
        case 'get_profile':
          result = await _getProfile(input);
          break;
        case 'update_profile':
          result = await _updateProfile(input);
          break;
        case 'save_habit':
          result = await _saveHabit(input);
          break;
        case 'get_habits':
          result = await _getHabits(input);
          break;
        case 'save_query':
          result = await _saveQuery(input);
          break;
        case 'get_query_history':
          result = await _getQueryHistory(input);
          break;
        default:
          throw ArgumentError('Unknown action: $action');
      }

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: action,
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Memory operation failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: input['action'] as String? ?? 'unknown',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _getProfile(Map<String, dynamic> input) async {
    final userId = input['userId'] as String? ?? 'default';

    final profile = _userProfileBox?.get(userId);

    if (profile == null) {
      // Return default profile
      return {'success': true, 'profile': null, 'isDefault': true};
    }

    return {'success': true, 'profile': profile.toJson(), 'isDefault': false};
  }

  Future<Map<String, dynamic>> _updateProfile(
    Map<String, dynamic> input,
  ) async {
    final userId = input['userId'] as String? ?? 'default';
    final profileData = input['profile'] as Map<String, dynamic>?;

    if (profileData == null) {
      throw ArgumentError('Profile data is required');
    }

    final existingProfile = _userProfileBox?.get(userId);

    final profile =
        existingProfile?.copyWith(
          name: profileData['name'] as String?,
          age: profileData['age'] as int?,
          city: profileData['city'] as String?,
          latitude: profileData['latitude'] as double?,
          longitude: profileData['longitude'] as double?,
          hasRespiratoryIssues: profileData['hasRespiratoryIssues'] as bool?,
          hasHeartCondition: profileData['hasHeartCondition'] as bool?,
          isPregnant: profileData['isPregnant'] as bool?,
          dailyRoutes: (profileData['dailyRoutes'] as List?)?.cast<String>(),
          preferences: profileData['preferences'] as Map<String, dynamic>?,
        ) ??
        UserProfile(
          userId: userId,
          name: profileData['name'] as String?,
          age: profileData['age'] as int?,
          city: profileData['city'] as String? ?? 'Unknown',
          latitude: profileData['latitude'] as double? ?? 0.0,
          longitude: profileData['longitude'] as double? ?? 0.0,
          hasRespiratoryIssues:
              profileData['hasRespiratoryIssues'] as bool? ?? false,
          hasHeartCondition: profileData['hasHeartCondition'] as bool? ?? false,
          isPregnant: profileData['isPregnant'] as bool? ?? false,
          dailyRoutes:
              (profileData['dailyRoutes'] as List?)?.cast<String>() ?? [],
          preferences:
              profileData['preferences'] as Map<String, dynamic>? ?? {},
        );

    await _userProfileBox?.put(userId, profile);

    return {'success': true, 'profile': profile.toJson()};
  }

  Future<Map<String, dynamic>> _saveHabit(Map<String, dynamic> input) async {
    final userId = input['userId'] as String? ?? 'default';
    final habitType = input['habitType'] as String?;
    final habitData = input['habitData'] as Map<String, dynamic>?;

    if (habitType == null || habitData == null) {
      throw ArgumentError('Habit type and data are required');
    }

    final habitKey = '${userId}_$habitType';
    final existingHabits =
        _habitsBox?.get(habitKey, defaultValue: <String, dynamic>{}) ?? {};

    final timestamp = DateTime.now().toIso8601String();
    existingHabits[timestamp] = habitData;

    await _habitsBox?.put(habitKey, existingHabits);

    return {'success': true, 'habitType': habitType, 'saved': true};
  }

  Future<Map<String, dynamic>> _getHabits(Map<String, dynamic> input) async {
    final userId = input['userId'] as String? ?? 'default';
    final habitType = input['habitType'] as String?;

    if (habitType == null) {
      // Get all habits for user
      final allHabits = <String, dynamic>{};
      for (final key in _habitsBox?.keys ?? []) {
        if (key.toString().startsWith(userId)) {
          final type = key.toString().split('_').last;
          allHabits[type] = _habitsBox?.get(key);
        }
      }

      return {'success': true, 'habits': allHabits};
    } else {
      final habitKey = '${userId}_$habitType';
      final habits = _habitsBox?.get(
        habitKey,
        defaultValue: <String, dynamic>{},
      );

      return {'success': true, 'habitType': habitType, 'habits': habits};
    }
  }

  Future<Map<String, dynamic>> _saveQuery(Map<String, dynamic> input) async {
    final userId = input['userId'] as String? ?? 'default';
    final query = input['query'] as String?;
    final response = input['response'] as Map<String, dynamic>?;

    if (query == null) {
      throw ArgumentError('Query is required');
    }

    final queryKey = userId;
    final existingQueries =
        _queriesBox?.get(queryKey, defaultValue: <String, dynamic>{}) ?? {};

    final timestamp = DateTime.now().toIso8601String();
    existingQueries[timestamp] = {'query': query, 'response': response};

    // Keep only last 100 queries
    if (existingQueries.length > 100) {
      final sortedKeys = existingQueries.keys.toList()..sort();
      for (var i = 0; i < existingQueries.length - 100; i++) {
        existingQueries.remove(sortedKeys[i]);
      }
    }

    await _queriesBox?.put(queryKey, existingQueries);

    return {'success': true, 'saved': true};
  }

  Future<Map<String, dynamic>> _getQueryHistory(
    Map<String, dynamic> input,
  ) async {
    final userId = input['userId'] as String? ?? 'default';
    final limit = input['limit'] as int? ?? 10;

    final queries =
        _queriesBox?.get(userId, defaultValue: <String, dynamic>{}) ?? {};

    final sortedEntries =
        queries.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)); // Most recent first

    final recentQueries =
        sortedEntries
            .take(limit)
            .map(
              (e) => {'timestamp': e.key, ...e.value as Map<String, dynamic>},
            )
            .toList();

    return {'success': true, 'queries': recentQueries, 'total': queries.length};
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'get_profile',
        description: 'Get user profile',
        schema: {
          'properties': {
            'userId': {'type': 'string'},
          },
        },
        execute: (params) => _getProfile(params),
      ),
      AgentTool(
        name: 'update_profile',
        description: 'Update user profile',
        schema: {
          'required': ['profile'],
          'properties': {
            'userId': {'type': 'string'},
            'profile': {'type': 'object'},
          },
        },
        execute: (params) => _updateProfile(params),
      ),
      AgentTool(
        name: 'save_habit',
        description: 'Save user habit',
        schema: {
          'required': ['habitType', 'habitData'],
          'properties': {
            'userId': {'type': 'string'},
            'habitType': {'type': 'string'},
            'habitData': {'type': 'object'},
          },
        },
        execute: (params) => _saveHabit(params),
      ),
    ];
  }

  /// Close all boxes
  Future<void> dispose() async {
    await _userProfileBox?.close();
    await _habitsBox?.close();
    await _queriesBox?.close();
  }
}

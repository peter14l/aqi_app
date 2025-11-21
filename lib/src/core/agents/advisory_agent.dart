import '../agents/agent_base.dart';
import '../services/llm_service.dart';
import '../services/agent_logger.dart';

/// Advisory Agent - Generates personalized recommendations based on AQI and user profile
class AdvisoryAgent extends AgentBase {
  final LlmService _llmService;
  final AgentLogger _agentLogger = AgentLogger();

  AdvisoryAgent({required LlmService llmService})
    : _llmService = llmService,
      super(name: 'AdvisoryAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Generating recommendations: $input');

      final aqi = input['aqi'] as int?;
      final userActivity = input['userActivity'] as String? ?? 'general';
      final userProfile = input['userProfile'] as Map<String, dynamic>? ?? {};

      if (aqi == null) {
        throw ArgumentError('AQI is required');
      }

      // Generate base recommendations
      final baseRecommendations = _generateBaseRecommendations(aqi);

      // Generate personalized recommendations using LLM
      List<String> personalizedRecommendations = [];
      try {
        personalizedRecommendations = await _llmService.generateRecommendations(
          aqi: aqi,
          userActivity: userActivity,
          userProfile: userProfile,
        );
      } catch (e) {
        logWarning(
          'LLM recommendations failed, using base recommendations: $e',
        );
        personalizedRecommendations = baseRecommendations;
      }

      // Calculate risk level
      final riskLevel = _calculateRiskLevel(aqi, userProfile);

      // Generate action items
      final actions = _generateActions(aqi, userActivity);

      final result = {
        'success': true,
        'recommendations':
            personalizedRecommendations.isNotEmpty
                ? personalizedRecommendations
                : baseRecommendations,
        'riskLevel': riskLevel,
        'actions': actions,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'advise',
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Advisory generation failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'advise',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  List<String> _generateBaseRecommendations(int aqi) {
    if (aqi <= 50) {
      return [
        'Air quality is good - enjoy outdoor activities',
        'No special precautions needed',
        'Great day for exercise and outdoor recreation',
      ];
    } else if (aqi <= 100) {
      return [
        'Air quality is acceptable for most people',
        'Unusually sensitive individuals should consider limiting prolonged outdoor exertion',
        'Monitor your symptoms if you have respiratory conditions',
      ];
    } else if (aqi <= 150) {
      return [
        'Sensitive groups should reduce prolonged outdoor exertion',
        'Consider wearing a mask if you have respiratory issues',
        'Keep windows closed if possible',
        'Limit outdoor activities for children and elderly',
      ];
    } else if (aqi <= 200) {
      return [
        'Everyone should reduce prolonged outdoor exertion',
        'Wear an N95 mask when going outside',
        'Keep windows and doors closed',
        'Use air purifiers indoors if available',
        'Avoid outdoor exercise',
      ];
    } else if (aqi <= 300) {
      return [
        'Avoid all outdoor activities',
        'Stay indoors with windows closed',
        'Use air purifiers on high setting',
        'Wear N95 masks even for brief outdoor exposure',
        'Monitor health symptoms closely',
      ];
    } else {
      return [
        'Health emergency - stay indoors',
        'Seal windows and doors',
        'Run air purifiers continuously',
        'Avoid all outdoor exposure',
        'Seek medical attention if experiencing symptoms',
      ];
    }
  }

  String _calculateRiskLevel(int aqi, Map<String, dynamic> userProfile) {
    final hasRespiratoryIssues =
        userProfile['hasRespiratoryIssues'] as bool? ?? false;
    final age = userProfile['age'] as int? ?? 30;
    final isPregnant = userProfile['isPregnant'] as bool? ?? false;

    // Base risk from AQI
    String baseRisk;
    if (aqi <= 50) {
      baseRisk = 'Low';
    } else if (aqi <= 100) {
      baseRisk = 'Low-Moderate';
    } else if (aqi <= 150) {
      baseRisk = 'Moderate';
    } else if (aqi <= 200) {
      baseRisk = 'High';
    } else if (aqi <= 300) {
      baseRisk = 'Very High';
    } else {
      baseRisk = 'Extreme';
    }

    // Adjust for user factors
    if (hasRespiratoryIssues || age > 65 || age < 12 || isPregnant) {
      if (aqi > 100) {
        return 'Elevated - $baseRisk (Sensitive Individual)';
      }
    }

    return baseRisk;
  }

  List<Map<String, String>> _generateActions(int aqi, String userActivity) {
    final actions = <Map<String, String>>[];

    if (aqi > 100) {
      actions.add({'action': 'Check AQI before going out', 'priority': 'high'});
    }

    if (aqi > 150) {
      actions.add({'action': 'Wear N95 mask outdoors', 'priority': 'high'});
      actions.add({'action': 'Close windows and doors', 'priority': 'medium'});
    }

    if (aqi > 200) {
      actions.add({'action': 'Cancel outdoor plans', 'priority': 'critical'});
      actions.add({'action': 'Run air purifier', 'priority': 'high'});
    }

    if (userActivity == 'exercise' && aqi > 100) {
      actions.add({'action': 'Move workout indoors', 'priority': 'high'});
    }

    if (userActivity == 'commute' && aqi > 150) {
      actions.add({
        'action': 'Consider working from home',
        'priority': 'medium',
      });
      actions.add({
        'action': 'Use air-conditioned transport',
        'priority': 'medium',
      });
    }

    return actions;
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'generate_recommendations',
        description: 'Generate personalized AQI recommendations',
        schema: {
          'required': ['aqi'],
          'properties': {
            'aqi': {'type': 'integer'},
            'userActivity': {'type': 'string'},
            'userProfile': {'type': 'object'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

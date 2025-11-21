import '../agents/agent_base.dart';
import '../services/llm_service.dart';
import '../services/agent_logger.dart';

/// Simulation Agent - Runs "what-if" scenarios for AQI projections
class SimulationAgent extends AgentBase {
  final LlmService _llmService;
  final AgentLogger _agentLogger = AgentLogger();

  SimulationAgent({required LlmService llmService})
    : _llmService = llmService,
      super(name: 'SimulationAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Running simulation: $input');

      final scenario = input['scenario'] as String?;
      final currentData = input['currentData'] as Map<String, dynamic>? ?? {};
      final historicalData = input['historicalData'] as List<dynamic>? ?? [];

      if (scenario == null || scenario.isEmpty) {
        throw ArgumentError('Scenario description is required');
      }

      // Run simulation based on scenario type
      Map<String, dynamic> simulationResult;

      if (scenario.contains('increase') || scenario.contains('decrease')) {
        simulationResult = await _runChangeSimulation(
          scenario: scenario,
          currentData: currentData,
          historicalData: historicalData,
        );
      } else if (scenario.contains('traffic') ||
          scenario.contains('emission')) {
        simulationResult = await _runTrafficSimulation(
          scenario: scenario,
          currentData: currentData,
        );
      } else if (scenario.contains('weather') || scenario.contains('rain')) {
        simulationResult = await _runWeatherSimulation(
          scenario: scenario,
          currentData: currentData,
        );
      } else {
        // Generic simulation using LLM
        simulationResult = await _runGenericSimulation(
          scenario: scenario,
          currentData: currentData,
          historicalData: historicalData,
        );
      }

      final result = {
        'success': true,
        'scenario': scenario,
        'simulation': simulationResult,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'simulate',
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Simulation failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'simulate',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _runChangeSimulation({
    required String scenario,
    required Map<String, dynamic> currentData,
    required List<dynamic> historicalData,
  }) async {
    final currentAqi = currentData['aqi'] as int? ?? 50;

    // Extract percentage change from scenario
    final percentageMatch = RegExp(r'(\d+)%').firstMatch(scenario);
    final percentage =
        percentageMatch != null ? int.parse(percentageMatch.group(1)!) : 20;

    final isIncrease = scenario.toLowerCase().contains('increase');
    final multiplier =
        isIncrease ? (1 + percentage / 100) : (1 - percentage / 100);

    final projectedAqi = (currentAqi * multiplier).round().clamp(0, 500);

    return {
      'currentAqi': currentAqi,
      'projectedAqi': projectedAqi,
      'change': projectedAqi - currentAqi,
      'changePercent': percentage * (isIncrease ? 1 : -1),
      'healthImpact': _getHealthImpact(currentAqi, projectedAqi),
      'recommendations': _getSimulationRecommendations(projectedAqi),
    };
  }

  Future<Map<String, dynamic>> _runTrafficSimulation({
    required String scenario,
    required Map<String, dynamic> currentData,
  }) async {
    final currentAqi = currentData['aqi'] as int? ?? 50;

    // Traffic typically increases PM2.5 and PM10
    final trafficImpact = scenario.toLowerCase().contains('reduce') ? -15 : 25;
    final projectedAqi = (currentAqi + trafficImpact).clamp(0, 500);

    return {
      'currentAqi': currentAqi,
      'projectedAqi': projectedAqi,
      'trafficImpact': trafficImpact,
      'primaryPollutant': 'PM2.5 and PM10 from vehicle emissions',
      'timeframe': '2-4 hours after traffic change',
      'recommendations': _getSimulationRecommendations(projectedAqi),
    };
  }

  Future<Map<String, dynamic>> _runWeatherSimulation({
    required String scenario,
    required Map<String, dynamic> currentData,
  }) async {
    final currentAqi = currentData['aqi'] as int? ?? 50;

    // Rain typically improves AQI
    final weatherImpact = scenario.toLowerCase().contains('rain') ? -20 : 10;
    final projectedAqi = (currentAqi + weatherImpact).clamp(0, 500);

    return {
      'currentAqi': currentAqi,
      'projectedAqi': projectedAqi,
      'weatherImpact': weatherImpact,
      'mechanism':
          scenario.toLowerCase().contains('rain')
              ? 'Rain washes particulates from the air'
              : 'Weather conditions may trap pollutants',
      'duration': '6-12 hours',
      'recommendations': _getSimulationRecommendations(projectedAqi),
    };
  }

  Future<Map<String, dynamic>> _runGenericSimulation({
    required String scenario,
    required Map<String, dynamic> currentData,
    required List<dynamic> historicalData,
  }) async {
    try {
      // Cast historicalData to the correct type
      final typedHistoricalData =
          historicalData.map((e) => e as Map<String, dynamic>).toList();

      final llmResult = await _llmService.simulateScenario(
        scenario: scenario,
        currentData: currentData,
        historicalData: typedHistoricalData,
      );

      return {'analysis': llmResult, 'method': 'LLM-based simulation'};
    } catch (e) {
      logWarning('LLM simulation failed, using fallback: $e');
      return {
        'analysis':
            'Unable to simulate this specific scenario. Please try a more specific scenario like "What if AQI increases by 30%?" or "What if traffic reduces by half?"',
        'method': 'fallback',
      };
    }
  }

  String _getHealthImpact(int currentAqi, int projectedAqi) {
    final change = projectedAqi - currentAqi;

    if (change.abs() < 10) {
      return 'Minimal change in health impact expected';
    } else if (change > 0) {
      if (projectedAqi > 150) {
        return 'Significant increase in health risks, especially for sensitive groups. Outdoor activities should be limited.';
      } else if (projectedAqi > 100) {
        return 'Moderate increase in health risks. Sensitive individuals should take precautions.';
      } else {
        return 'Slight increase in health risks. Most people will not be affected.';
      }
    } else {
      if (projectedAqi < 50) {
        return 'Excellent improvement! Air quality will be safe for all outdoor activities.';
      } else if (projectedAqi < 100) {
        return 'Good improvement in air quality. Reduced health risks for most people.';
      } else {
        return 'Some improvement, but caution still advised for sensitive groups.';
      }
    }
  }

  List<String> _getSimulationRecommendations(int projectedAqi) {
    if (projectedAqi <= 50) {
      return [
        'Safe for all outdoor activities',
        'No special precautions needed',
      ];
    } else if (projectedAqi <= 100) {
      return [
        'Generally safe for most people',
        'Sensitive individuals should monitor symptoms',
      ];
    } else if (projectedAqi <= 150) {
      return [
        'Limit prolonged outdoor exertion',
        'Consider wearing masks for sensitive groups',
        'Monitor air quality updates',
      ];
    } else {
      return [
        'Avoid outdoor activities',
        'Keep windows closed',
        'Use air purifiers',
        'Wear N95 masks if going outside',
      ];
    }
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'simulate_scenario',
        description: 'Run what-if scenarios for AQI changes',
        schema: {
          'required': ['scenario'],
          'properties': {
            'scenario': {'type': 'string'},
            'currentData': {'type': 'object'},
            'historicalData': {'type': 'array'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

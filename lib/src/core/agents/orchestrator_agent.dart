import '../agents/agent_base.dart';
import '../agents/data_fetch_agent.dart';
import '../agents/analysis_agent.dart';
import '../agents/advisory_agent.dart';
import '../agents/prediction_agent.dart';
import '../agents/simulation_agent.dart';
import '../agents/route_exposure_agent.dart';
import '../services/agent_logger.dart';

/// Orchestrator Agent - Routes queries and coordinates multi-agent workflows
class OrchestratorAgent extends AgentBase {
  final DataFetchAgent dataFetchAgent;
  final AnalysisAgent analysisAgent;
  final AdvisoryAgent advisoryAgent;
  final PredictionAgent predictionAgent;
  final SimulationAgent simulationAgent;
  final RouteExposureAgent? routeExposureAgent;
  final AgentLogger _agentLogger = AgentLogger();

  OrchestratorAgent({
    required this.dataFetchAgent,
    required this.analysisAgent,
    required this.advisoryAgent,
    required this.predictionAgent,
    required this.simulationAgent,
    this.routeExposureAgent,
  }) : super(name: 'OrchestratorAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Orchestrating request: $input');

      final query = input['query'] as String?;
      final queryType =
          input['queryType'] as String? ?? _detectQueryType(query ?? '');

      Map<String, dynamic> result;

      switch (queryType) {
        case 'current_status':
          result = await _handleCurrentStatus(input);
          break;
        case 'prediction':
          result = await _handlePrediction(input);
          break;
        case 'recommendation':
          result = await _handleRecommendation(input);
          break;
        case 'simulation':
          result = await _handleSimulation(input);
          break;
        case 'full_analysis':
          result = await _handleFullAnalysis(input);
          break;
        default:
          result = await _handleFullAnalysis(input);
      }

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'orchestrate_$queryType',
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Orchestration failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'orchestrate',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  String _detectQueryType(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('predict') ||
        lowerQuery.contains('forecast') ||
        lowerQuery.contains('tomorrow')) {
      return 'prediction';
    } else if (lowerQuery.contains('recommend') ||
        lowerQuery.contains('should i') ||
        lowerQuery.contains('advice')) {
      return 'recommendation';
    } else if (lowerQuery.contains('what if') ||
        lowerQuery.contains('simulate') ||
        lowerQuery.contains('scenario')) {
      return 'simulation';
    } else if (lowerQuery.contains('current') ||
        lowerQuery.contains('now') ||
        lowerQuery.contains('today')) {
      return 'current_status';
    }

    return 'full_analysis';
  }

  /// Handle current status query - Sequential: Fetch → Analyze
  Future<Map<String, dynamic>> _handleCurrentStatus(
    Map<String, dynamic> input,
  ) async {
    logInfo('Handling current status query');

    // Step 1: Fetch current data
    final fetchResult = await dataFetchAgent.execute({
      'action': 'realtime_aqi',
      'lat': input['lat'] ?? 50.0647,
      'lon': input['lon'] ?? 19.9450,
    });

    final weatherResult = await dataFetchAgent.execute({
      'action': 'realtime_weather',
      'lat': input['lat'] ?? 50.0647,
      'lon': input['lon'] ?? 19.9450,
    });

    // Step 2: Analyze the data
    final analysisResult = await analysisAgent.execute({
      'aqi': fetchResult['aqi'],
      'pm25': fetchResult['pm25'],
      'pm10': fetchResult['pm10'],
      'location': fetchResult['location'],
      'weatherData': weatherResult,
    });

    return {
      'queryType': 'current_status',
      'data': fetchResult,
      'weather': weatherResult,
      'analysis': analysisResult,
    };
  }

  /// Handle prediction query - Sequential: Fetch → History → Predict
  Future<Map<String, dynamic>> _handlePrediction(
    Map<String, dynamic> input,
  ) async {
    logInfo('Handling prediction query');

    // Step 1: Fetch current data
    final fetchResult = await dataFetchAgent.execute({
      'action': 'realtime_aqi',
      'lat': input['lat'] ?? 50.0647,
      'lon': input['lon'] ?? 19.9450,
    });

    // Step 2: Fetch historical data
    final historyResult = await dataFetchAgent.execute({
      'action': 'history_aqi',
      'lat': input['lat'] ?? 50.0647,
      'lon': input['lon'] ?? 19.9450,
      'days': 7,
    });

    // Step 3: Generate predictions
    final predictionResult = await predictionAgent.execute({
      'currentAqi': fetchResult['aqi'],
      'historicalData': historyResult['data'],
      'hours': input['hours'] ?? 24,
    });

    return {
      'queryType': 'prediction',
      'current': fetchResult,
      'historical': historyResult,
      'predictions': predictionResult,
    };
  }

  /// Handle recommendation query - Parallel: Fetch + Analyze, then Advise
  Future<Map<String, dynamic>> _handleRecommendation(
    Map<String, dynamic> input,
  ) async {
    logInfo('Handling recommendation query');

    // Parallel: Fetch AQI and Weather
    final results = await Future.wait([
      dataFetchAgent.execute({
        'action': 'realtime_aqi',
        'lat': input['lat'] ?? 50.0647,
        'lon': input['lon'] ?? 19.9450,
      }),
      dataFetchAgent.execute({
        'action': 'realtime_weather',
        'lat': input['lat'] ?? 50.0647,
        'lon': input['lon'] ?? 19.9450,
      }),
    ]);

    final fetchResult = results[0];
    final weatherResult = results[1];

    // Generate recommendations
    final advisoryResult = await advisoryAgent.execute({
      'aqi': fetchResult['aqi'],
      'userActivity': input['userActivity'] ?? 'general',
      'userProfile': input['userProfile'] ?? {},
    });

    return {
      'queryType': 'recommendation',
      'data': fetchResult,
      'weather': weatherResult,
      'recommendations': advisoryResult,
    };
  }

  /// Handle simulation query
  Future<Map<String, dynamic>> _handleSimulation(
    Map<String, dynamic> input,
  ) async {
    logInfo('Handling simulation query');

    // Fetch current data
    final fetchResult = await dataFetchAgent.execute({
      'action': 'realtime_aqi',
      'lat': input['lat'] ?? 50.0647,
      'lon': input['lon'] ?? 19.9450,
    });

    // Fetch historical data
    final historyResult = await dataFetchAgent.execute({
      'action': 'history_aqi',
      'lat': input['lat'] ?? 50.0647,
      'lon': input['lon'] ?? 19.9450,
      'days': 7,
    });

    // Run simulation
    final simulationResult = await simulationAgent.execute({
      'scenario': input['scenario'] ?? input['query'],
      'currentData': fetchResult,
      'historicalData': historyResult['data'],
    });

    return {
      'queryType': 'simulation',
      'current': fetchResult,
      'simulation': simulationResult,
    };
  }

  /// Handle full analysis - Complete workflow
  Future<Map<String, dynamic>> _handleFullAnalysis(
    Map<String, dynamic> input,
  ) async {
    logInfo('Handling full analysis query');

    // Step 1: Parallel fetch
    final fetchResults = await Future.wait([
      dataFetchAgent.execute({
        'action': 'realtime_aqi',
        'lat': input['lat'] ?? 50.0647,
        'lon': input['lon'] ?? 19.9450,
      }),
      dataFetchAgent.execute({
        'action': 'realtime_weather',
        'lat': input['lat'] ?? 50.0647,
        'lon': input['lon'] ?? 19.9450,
      }),
      dataFetchAgent.execute({
        'action': 'history_aqi',
        'lat': input['lat'] ?? 50.0647,
        'lon': input['lon'] ?? 19.9450,
        'days': 7,
      }),
    ]);

    final aqiData = fetchResults[0];
    final weatherData = fetchResults[1];
    final historyData = fetchResults[2];

    // Step 2: Parallel analysis and prediction
    final analysisResults = await Future.wait([
      analysisAgent.execute({
        'aqi': aqiData['aqi'],
        'pm25': aqiData['pm25'],
        'pm10': aqiData['pm10'],
        'location': aqiData['location'],
        'weatherData': weatherData,
      }),
      predictionAgent.execute({
        'currentAqi': aqiData['aqi'],
        'historicalData': historyData['data'],
        'hours': 24,
      }),
    ]);

    final analysis = analysisResults[0];
    final predictions = analysisResults[1];

    // Step 3: Generate recommendations
    final recommendations = await advisoryAgent.execute({
      'aqi': aqiData['aqi'],
      'userActivity': input['userActivity'] ?? 'general',
      'userProfile': input['userProfile'] ?? {},
    });

    return {
      'queryType': 'full_analysis',
      'data': aqiData,
      'weather': weatherData,
      'historical': historyData,
      'analysis': analysis,
      'predictions': predictions,
      'recommendations': recommendations,
    };
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'orchestrate',
        description: 'Coordinate multiple agents to answer complex queries',
        schema: {
          'properties': {
            'query': {'type': 'string'},
            'queryType': {'type': 'string'},
            'lat': {'type': 'number'},
            'lon': {'type': 'number'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

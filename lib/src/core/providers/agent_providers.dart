import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../agents/orchestrator_agent.dart';
import '../agents/data_fetch_agent.dart';
import '../agents/analysis_agent.dart';
import '../agents/advisory_agent.dart';
import '../agents/prediction_agent.dart';
import '../agents/simulation_agent.dart';
import '../agents/memory_agent.dart';
import '../agents/route_exposure_agent.dart';
import '../services/llm_service.dart';

/// Provider for LLM Service - Async initialization
final llmServiceProvider = FutureProvider<LlmService>((ref) async {
  try {
    return await LlmService.create();
  } catch (e) {
    // If API key is missing, create a dummy service that will error gracefully
    throw Exception(
      'LLM Service initialization failed: $e. Please add GEMINI_API_KEY to .env file',
    );
  }
});

/// Provider for Data Fetch Agent
final dataFetchAgentProvider = Provider<DataFetchAgent>((ref) {
  return DataFetchAgent();
});

/// Provider for Analysis Agent - Async to wait for LLM service
final analysisAgentProvider = FutureProvider<AnalysisAgent>((ref) async {
  final llmService = await ref.watch(llmServiceProvider.future);
  return AnalysisAgent(llmService: llmService);
});

/// Provider for Advisory Agent - Async to wait for LLM service
final advisoryAgentProvider = FutureProvider<AdvisoryAgent>((ref) async {
  final llmService = await ref.watch(llmServiceProvider.future);
  return AdvisoryAgent(llmService: llmService);
});

/// Provider for Prediction Agent
final predictionAgentProvider = Provider<PredictionAgent>((ref) {
  return PredictionAgent();
});

/// Provider for Simulation Agent - Async to wait for LLM service
final simulationAgentProvider = FutureProvider<SimulationAgent>((ref) async {
  final llmService = await ref.watch(llmServiceProvider.future);
  return SimulationAgent(llmService: llmService);
});

/// Provider for Memory Agent
final memoryAgentProvider = Provider<MemoryAgent>((ref) {
  final agent = MemoryAgent();
  // Initialize in the background
  agent.initialize();
  return agent;
});

/// Provider for Route Exposure Agent
final routeExposureAgentProvider = Provider<RouteExposureAgent>((ref) {
  return RouteExposureAgent();
});

/// Provider for Orchestrator Agent - Async to wait for all agents
final orchestratorAgentProvider = FutureProvider<OrchestratorAgent>((
  ref,
) async {
  final dataFetchAgent = ref.watch(dataFetchAgentProvider);
  final analysisAgent = await ref.watch(analysisAgentProvider.future);
  final advisoryAgent = await ref.watch(advisoryAgentProvider.future);
  final predictionAgent = ref.watch(predictionAgentProvider);
  final simulationAgent = await ref.watch(simulationAgentProvider.future);
  final routeExposureAgent = ref.watch(routeExposureAgentProvider);

  return OrchestratorAgent(
    dataFetchAgent: dataFetchAgent,
    analysisAgent: analysisAgent,
    advisoryAgent: advisoryAgent,
    predictionAgent: predictionAgent,
    simulationAgent: simulationAgent,
    routeExposureAgent: routeExposureAgent,
  );
});

/// Provider for executing agent queries
final agentQueryProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      input,
    ) async {
      final orchestrator = await ref.watch(orchestratorAgentProvider.future);
      return await orchestrator.execute(input);
    });

/// Provider for user profile
final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final memoryAgent = ref.watch(memoryAgentProvider);
  return await memoryAgent.execute({'action': 'get_profile'});
});

/// Provider for current AQI with agent analysis
final currentAqiWithAnalysisProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final orchestrator = await ref.watch(orchestratorAgentProvider.future);

  return await orchestrator.execute({
    'queryType': 'current_status',
    'lat': 50.0647, // Cracow coordinates
    'lon': 19.9450,
  });
});

/// Provider for AQI predictions
final aqiPredictionsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final orchestrator = await ref.watch(orchestratorAgentProvider.future);

  return await orchestrator.execute({
    'queryType': 'prediction',
    'lat': 50.0647,
    'lon': 19.9450,
    'hours': 24,
  });
});

/// Provider for personalized recommendations
final recommendationsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, activity) async {
      final orchestrator = await ref.watch(orchestratorAgentProvider.future);
      final userProfile = await ref.watch(userProfileProvider.future);

      return await orchestrator.execute({
        'queryType': 'recommendation',
        'lat': 50.0647,
        'lon': 19.9450,
        'userActivity': activity,
        'userProfile': userProfile['profile'] ?? {},
      });
    });

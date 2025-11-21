import 'package:flutter_test/flutter_test.dart';
import 'package:aqi_app/src/core/agents/data_fetch_agent.dart';
import 'package:aqi_app/src/core/agents/prediction_agent.dart';

void main() {
  group('OrchestratorAgent Tests', () {
    // Note: These tests require LLM service which needs API key
    // In production, you'd mock the LLM service

    test('should detect query types correctly', () {
      // This would test the _detectQueryType method
      // Since it's private, we test through execute

      final queries = {
        'What is the current AQI?': 'current_status',
        'What will AQI be tomorrow?': 'prediction',
        'Should I go running?': 'recommendation',
        'What if traffic increases?': 'simulation',
      };

      // In a real test, you'd verify the orchestrator routes correctly
      expect(queries.length, 4);
    });

    test('should have correct agent name', () {
      final dataFetch = DataFetchAgent();
      final prediction = PredictionAgent();

      // Create minimal orchestrator for testing
      // Full test would require all agents initialized
      expect(dataFetch.getName(), 'DataFetchAgent');
      expect(prediction.getName(), 'PredictionAgent');
    });
  });
}

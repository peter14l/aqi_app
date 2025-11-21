import 'package:flutter_test/flutter_test.dart';
import 'package:aqi_app/src/core/agents/data_fetch_agent.dart';

void main() {
  group('DataFetchAgent Tests', () {
    late DataFetchAgent agent;

    setUp(() {
      agent = DataFetchAgent();
    });

    test('should have correct agent name', () {
      expect(agent.getName(), 'DataFetchAgent');
    });

    test('should have three tools', () {
      final tools = agent.getTools();
      expect(tools.length, 3);
      expect(tools[0].name, 'realtime_aqi');
      expect(tools[1].name, 'realtime_weather');
      expect(tools[2].name, 'history_aqi');
    });

    test('should validate tool parameters correctly', () {
      final tools = agent.getTools();
      final aqiTool = tools[0];

      // Valid params
      expect(aqiTool.validateParams({'lat': 50.0, 'lon': 19.0}), true);

      // Missing required param
      expect(aqiTool.validateParams({'lat': 50.0}), false);

      // Empty params
      expect(aqiTool.validateParams({}), false);
    });

    test('should throw error for missing action', () async {
      expect(
        () async => await agent.execute({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for unknown action', () async {
      expect(
        () async => await agent.execute({'action': 'invalid_action'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    // Note: Real API tests would require mocking or integration testing
    // These are structural tests only
  });
}

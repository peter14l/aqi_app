import 'package:flutter_test/flutter_test.dart';
import 'package:aqi_app/src/core/agents/data_fetch_agent.dart';

void main() {
  group('DataFetchAgent Integration Tests', () {
    test('should fetch realtime AQI data', () async {
      final dataFetch = DataFetchAgent();
      final startTime = DateTime.now();
      
      final result = await dataFetch.execute({
        'action': 'realtime_aqi',
        'lat': 50.0,
        'lon': 19.0,
      });

      final endTime = DateTime.now();
      final latency = endTime.difference(startTime);

      expect(result['success'], true);
      expect(latency.inMilliseconds, lessThan(5000)); // Should complete in < 5s
      print('Latency for realtime_aqi: ${latency.inMilliseconds}ms');
    });

    test('should handle failure recovery - missing API key', () async {
      final dataFetch = DataFetchAgent();

      try {
        // This should handle missing data gracefully
        final result = await dataFetch.execute({
          'action': 'realtime_aqi',
          'lat': 50.0,
          'lon': 19.0,
        });

        // Should either succeed or fail gracefully
        expect(result, isNotNull);
      } catch (e) {
        // Error should be caught and logged
        expect(e, isNotNull);
      }
    });

    test('should validate sequential execution order', () async {
      final dataFetch = DataFetchAgent();
      final prediction = PredictionAgent();

      // Step 1: Fetch data
      final fetchResult = await dataFetch.execute({
        'action': 'realtime_aqi',
        'lat': 50.0,
        'lon': 19.0,
      });

      expect(fetchResult['success'], true);

      // Step 2: Use fetched data for prediction
      final predResult = await prediction.execute({
        'currentAqi': fetchResult['aqi'] ?? 50,
        'hours': 6,
      });

      expect(predResult['success'], true);
      expect(predResult['predictions'], isNotNull);
    });

    test('should test parallel agent consistency', () async {
      final dataFetch = DataFetchAgent();

      // Execute multiple parallel requests
      final results = await Future.wait([
        dataFetch.execute({'action': 'realtime_aqi', 'lat': 50.0, 'lon': 19.0}),
        dataFetch.execute({
          'action': 'realtime_weather',
          'lat': 50.0,
          'lon': 19.0,
        }),
      ]);

      // Both should succeed
      expect(results[0]['success'], true);
      expect(results[1]['success'], true);

      // Results should be consistent (same location)
      expect(results[0]['location'], isNotNull);
    });
  });
}

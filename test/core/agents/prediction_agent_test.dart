import 'package:flutter_test/flutter_test.dart';
import 'package:aqi_app/src/core/agents/prediction_agent.dart';

void main() {
  group('PredictionAgent Tests', () {
    late PredictionAgent agent;

    setUp(() {
      agent = PredictionAgent();
    });

    test('should have correct agent name', () {
      expect(agent.getName(), 'PredictionAgent');
    });

    test('should generate predictions', () async {
      final result = await agent.execute({
        'currentAqi': 75,
        'historicalData': [
          {'aqi': 70},
          {'aqi': 72},
          {'aqi': 75},
        ],
        'hours': 6,
      });

      expect(result['success'], true);
      expect(result['predictions'], isNotNull);
      expect(result['predictions']['predictions'], isA<List>());
      expect(result['predictions']['confidence'], isA<double>());
    });

    test('should handle missing current AQI', () async {
      expect(
        () async => await agent.execute({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should generate correct number of predictions', () async {
      final result = await agent.execute({'currentAqi': 50, 'hours': 12});

      final predictions = result['predictions']['predictions'] as List;
      expect(predictions.length, 12);
    });

    test('should include confidence score', () async {
      final result = await agent.execute({
        'currentAqi': 50,
        'historicalData': List.generate(10, (i) => {'aqi': 50 + i}),
      });

      final confidence = result['predictions']['confidence'] as double;
      expect(confidence, greaterThan(0.0));
      expect(confidence, lessThanOrEqualTo(1.0));
    });

    test('should clamp AQI predictions to valid range', () async {
      final result = await agent.execute({'currentAqi': 450, 'hours': 24});

      final predictions = result['predictions']['predictions'] as List;
      for (final pred in predictions) {
        final aqi = pred['aqi'] as int;
        expect(aqi, greaterThanOrEqualTo(0));
        expect(aqi, lessThanOrEqualTo(500));
      }
    });
  });
}

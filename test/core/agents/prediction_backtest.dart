import 'package:flutter_test/flutter_test.dart';
import 'package:aqi_app/src/core/agents/prediction_agent.dart';

/// Import for sqrt function
import 'dart:math';

void main() {
  group('Prediction Backtesting', () {
    late PredictionAgent agent;

    setUp(() {
      agent = PredictionAgent();
    });

    test('should calculate RMSE for predictions', () {
      // Simulated actual vs predicted values
      final actual = [50, 55, 60, 65, 70, 75, 80];
      final predicted = [52, 54, 62, 64, 72, 76, 78];

      final rmse = _calculateRMSE(actual, predicted);

      expect(rmse, greaterThan(0));
      expect(rmse, lessThan(10)); // Should be reasonably accurate

      print('RMSE: ${rmse.toStringAsFixed(2)}');
    });

    test('should calculate MAE for predictions', () {
      final actual = [50, 55, 60, 65, 70, 75, 80];
      final predicted = [52, 54, 62, 64, 72, 76, 78];

      final mae = _calculateMAE(actual, predicted);

      expect(mae, greaterThan(0));
      expect(mae, lessThan(5)); // Should be reasonably accurate

      print('MAE: ${mae.toStringAsFixed(2)}');
    });

    test('should run 30-day train, 7-day predict backtest', () async {
      // Generate 30 days of historical data (simulated)
      final historicalData = List.generate(
        30,
        (i) => {
          'aqi': 50 + (i % 20), // Simulated pattern
          'timestamp': DateTime.now().subtract(Duration(days: 30 - i)),
        },
      );

      // Use last 7 days as test set
      final testData = historicalData.sublist(23, 30);
      final trainData = historicalData.sublist(0, 23);

      // Generate predictions for 7 days
      final predictions = <int>[];
      for (var i = 0; i < 7; i++) {
        final result = await agent.execute({
          'currentAqi': trainData.last['aqi'],
          'historicalData': trainData,
          'hours': 24,
        });

        final dayPredictions = result['predictions']['predictions'] as List;
        predictions.add(dayPredictions[0]['aqi'] as int);
      }

      // Calculate metrics
      final actualValues = testData.map((d) => d['aqi'] as int).toList();
      final rmse = _calculateRMSE(actualValues, predictions);
      final mae = _calculateMAE(actualValues, predictions);

      print('Backtest Results:');
      print('RMSE: ${rmse.toStringAsFixed(2)}');
      print('MAE: ${mae.toStringAsFixed(2)}');
      print('Accuracy: ${(100 - mae).toStringAsFixed(1)}%');

      expect(rmse, lessThan(30)); // Acceptable for simplified model
      expect(mae, lessThan(20)); // Acceptable for simplified model
    });

    test(
      'should calculate confidence based on historical data quality',
      () async {
        // Test with good historical data
        final goodHistory = List.generate(20, (i) => {'aqi': 50 + i});
        final result1 = await agent.execute({
          'currentAqi': 70,
          'historicalData': goodHistory,
          'hours': 6,
        });

        final confidence1 = result1['predictions']['confidence'] as double;
        expect(confidence1, greaterThan(0.6)); // Should have good confidence

        // Test with sparse historical data
        final sparseHistory = List.generate(3, (i) => {'aqi': 50});
        final result2 = await agent.execute({
          'currentAqi': 70,
          'historicalData': sparseHistory,
          'hours': 6,
        });

        final confidence2 = result2['predictions']['confidence'] as double;
        expect(confidence2, lessThan(0.5)); // Should have lower confidence
      },
    );
  });
}

/// Calculate Root Mean Square Error
double _calculateRMSE(List<int> actual, List<int> predicted) {
  if (actual.length != predicted.length) {
    throw ArgumentError('Actual and predicted lists must have same length');
  }

  double sumSquaredError = 0;
  for (var i = 0; i < actual.length; i++) {
    final error = actual[i] - predicted[i];
    sumSquaredError += error * error;
  }

  return sqrt(sumSquaredError / actual.length);
}

/// Calculate Mean Absolute Error
double _calculateMAE(List<int> actual, List<int> predicted) {
  if (actual.length != predicted.length) {
    throw ArgumentError('Actual and predicted lists must have same length');
  }

  double sumAbsoluteError = 0;
  for (var i = 0; i < actual.length; i++) {
    sumAbsoluteError += (actual[i] - predicted[i]).abs();
  }

  return sumAbsoluteError / actual.length;
}

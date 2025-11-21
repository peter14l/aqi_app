import '../agents/agent_base.dart';
import '../services/agent_logger.dart';

/// Prediction Agent - Predicts future AQI based on historical patterns and current trends
class PredictionAgent extends AgentBase {
  final AgentLogger _agentLogger = AgentLogger();

  PredictionAgent() : super(name: 'PredictionAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Predicting AQI: $input');

      final currentAqi = input['currentAqi'] as int?;
      final historicalData = input['historicalData'] as List<dynamic>? ?? [];
      final hours = input['hours'] as int? ?? 24;

      if (currentAqi == null) {
        throw ArgumentError('Current AQI is required');
      }

      // Simple prediction model based on trends
      // In production, this would use a proper ML model
      final predictions = _generatePredictions(
        currentAqi: currentAqi,
        historicalData: historicalData,
        hours: hours,
      );

      // Calculate confidence based on data availability
      final confidence = _calculateConfidence(historicalData);

      final result = {
        'success': true,
        'predictions': predictions,
        'confidence': confidence,
        'method': 'trend-based',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'predict',
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Prediction failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'predict',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  List<Map<String, dynamic>> _generatePredictions({
    required int currentAqi,
    required List<dynamic> historicalData,
    required int hours,
  }) {
    final predictions = <Map<String, dynamic>>[];

    // Calculate trend from historical data
    double trend = 0;
    if (historicalData.length >= 2) {
      final recent = historicalData.take(3).toList();
      final aqiValues =
          recent.map((d) => (d['aqi'] as num).toDouble()).toList();
      trend = (aqiValues.first - aqiValues.last) / recent.length;
    }

    // Generate hourly predictions
    for (int i = 1; i <= hours; i++) {
      final predictedTime = DateTime.now().add(Duration(hours: i));

      // Simple linear trend with some randomness for realism
      // In production, use proper ML model
      final trendComponent = trend * i;
      final seasonalComponent = _getSeasonalComponent(predictedTime);
      final randomComponent = (i % 3 - 1) * 2; // Small variation

      final predictedAqi =
          (currentAqi + trendComponent + seasonalComponent + randomComponent)
              .clamp(0, 500)
              .round();

      predictions.add({
        'hour': i,
        'timestamp': predictedTime.toIso8601String(),
        'aqi': predictedAqi,
        'status': _getAqiStatus(predictedAqi),
      });
    }

    return predictions;
  }

  double _getSeasonalComponent(DateTime time) {
    final hour = time.hour;

    // Morning rush hour (7-9 AM) - higher pollution
    if (hour >= 7 && hour <= 9) {
      return 10;
    }

    // Evening rush hour (5-7 PM) - higher pollution
    if (hour >= 17 && hour <= 19) {
      return 15;
    }

    // Late night (11 PM - 5 AM) - lower pollution
    if (hour >= 23 || hour <= 5) {
      return -10;
    }

    return 0;
  }

  String _getAqiStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  double _calculateConfidence(List<dynamic> historicalData) {
    if (historicalData.isEmpty) return 0.3;
    if (historicalData.length < 3) return 0.5;
    if (historicalData.length < 7) return 0.7;
    return 0.85;
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'predict_aqi',
        description: 'Predict future AQI values',
        schema: {
          'required': ['currentAqi'],
          'properties': {
            'currentAqi': {'type': 'integer'},
            'historicalData': {'type': 'array'},
            'hours': {'type': 'integer'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

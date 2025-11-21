import '../agents/agent_base.dart';
import '../services/agent_logger.dart';

/// Route Exposure Agent - Calculates PM exposure on commute routes
class RouteExposureAgent extends AgentBase {
  final AgentLogger _agentLogger = AgentLogger();

  RouteExposureAgent() : super(name: 'RouteExposureAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Calculating route exposure: $input');

      final route = input['route'] as List<dynamic>? ?? [];
      final aqiData = input['aqiData'] as Map<String, dynamic>? ?? {};

      if (route.isEmpty) {
        throw ArgumentError('Route coordinates are required');
      }

      // Calculate exposure for the route
      final exposure = _calculateRouteExposure(route, aqiData);

      // Score the route
      final score = _scoreRoute(exposure);

      // Generate alternative suggestions
      final suggestions = _generateSuggestions(score, exposure);

      final result = {
        'success': true,
        'route': route,
        'exposure': exposure,
        'score': score,
        'suggestions': suggestions,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'calculate_exposure',
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Route exposure calculation failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'calculate_exposure',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  Map<String, dynamic> _calculateRouteExposure(
    List<dynamic> route,
    Map<String, dynamic> aqiData,
  ) {
    // Simplified exposure calculation
    // In production, this would use actual route segments and AQI mapping

    final baseAqi = aqiData['aqi'] as int? ?? 50;
    final pm25 = aqiData['pm25'] as double? ?? 10.0;
    final pm10 = aqiData['pm10'] as double? ?? 20.0;

    // Assume 30 minute commute as default
    final durationMinutes = aqiData['durationMinutes'] as int? ?? 30;

    // Calculate exposure (simplified formula)
    final pm25Exposure = pm25 * durationMinutes / 60; // µg/m³ * hours
    final pm10Exposure = pm10 * durationMinutes / 60;
    final totalExposure = pm25Exposure + pm10Exposure;

    return {
      'pm25Exposure': pm25Exposure,
      'pm10Exposure': pm10Exposure,
      'totalExposure': totalExposure,
      'durationMinutes': durationMinutes,
      'averageAqi': baseAqi,
    };
  }

  Map<String, dynamic> _scoreRoute(Map<String, dynamic> exposure) {
    final totalExposure = exposure['totalExposure'] as double;
    final averageAqi = exposure['averageAqi'] as int;

    String rating;
    int score; // 0-100, higher is better

    if (averageAqi <= 50 && totalExposure < 20) {
      rating = 'Excellent';
      score = 95;
    } else if (averageAqi <= 100 && totalExposure < 40) {
      rating = 'Good';
      score = 75;
    } else if (averageAqi <= 150 && totalExposure < 60) {
      rating = 'Moderate';
      score = 50;
    } else if (averageAqi <= 200 && totalExposure < 80) {
      rating = 'Poor';
      score = 30;
    } else {
      rating = 'Very Poor';
      score = 10;
    }

    return {
      'rating': rating,
      'score': score,
      'healthImpact': _getHealthImpact(rating),
    };
  }

  String _getHealthImpact(String rating) {
    switch (rating) {
      case 'Excellent':
        return 'Minimal health impact. Safe for all activities.';
      case 'Good':
        return 'Low health impact. Generally safe for most people.';
      case 'Moderate':
        return 'Moderate health impact. Sensitive individuals should take precautions.';
      case 'Poor':
        return 'Significant health impact. Consider alternative routes or times.';
      case 'Very Poor':
        return 'Severe health impact. Strongly recommend avoiding this route.';
      default:
        return 'Unknown health impact.';
    }
  }

  List<String> _generateSuggestions(
    Map<String, dynamic> score,
    Map<String, dynamic> exposure,
  ) {
    final suggestions = <String>[];
    final rating = score['rating'] as String;
    final scoreValue = score['score'] as int;

    if (scoreValue < 50) {
      suggestions.add('Consider taking this route during off-peak hours');
      suggestions.add('Wear an N95 mask during commute');
      suggestions.add('Keep windows closed if driving');
    }

    if (scoreValue < 30) {
      suggestions.add('Look for alternative routes with less traffic');
      suggestions.add('Consider working from home if possible');
      suggestions.add('Use public transport with air filtration');
    }

    if (rating == 'Excellent' || rating == 'Good') {
      suggestions.add('Current route is optimal for air quality');
      suggestions.add('No special precautions needed');
    }

    return suggestions;
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'calculate_route_exposure',
        description: 'Calculate PM exposure on a commute route',
        schema: {
          'required': ['route'],
          'properties': {
            'route': {'type': 'array'},
            'aqiData': {'type': 'object'},
            'durationMinutes': {'type': 'integer'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

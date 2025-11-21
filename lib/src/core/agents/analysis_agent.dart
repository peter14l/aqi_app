import '../agents/agent_base.dart';
import '../services/llm_service.dart';
import '../services/agent_logger.dart';

/// Analysis Agent - Interprets data and generates insights using LLM
class AnalysisAgent extends AgentBase {
  final LlmService _llmService;
  final AgentLogger _agentLogger = AgentLogger();

  AnalysisAgent({required LlmService llmService})
    : _llmService = llmService,
      super(name: 'AnalysisAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Analyzing data: $input');

      final aqi = input['aqi'] as int?;
      final pm25 = input['pm25'] as double?;
      final pm10 = input['pm10'] as double?;
      final location = input['location'] as String? ?? 'Unknown';
      final weatherData = input['weatherData'] as Map<String, dynamic>? ?? {};

      if (aqi == null || pm25 == null || pm10 == null) {
        throw ArgumentError('AQI, PM2.5, and PM10 are required');
      }

      // Use LLM to analyze the data
      final analysis = await _llmService.analyzeAqiData(
        aqi: aqi,
        pm25: pm25,
        pm10: pm10,
        location: location,
        weatherData: weatherData,
      );

      // Determine health impact level
      final healthImpact = _determineHealthImpact(aqi);

      // Identify contributing factors
      final factors = _identifyFactors(aqi, pm25, pm10, weatherData);

      final result = {
        'success': true,
        'analysis': analysis,
        'healthImpact': healthImpact,
        'contributingFactors': factors,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'analyze',
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Analysis failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'analyze',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  String _determineHealthImpact(int aqi) {
    if (aqi <= 50) {
      return 'Good - Air quality is satisfactory, and air pollution poses little or no risk.';
    } else if (aqi <= 100) {
      return 'Moderate - Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution.';
    } else if (aqi <= 150) {
      return 'Unhealthy for Sensitive Groups - Members of sensitive groups may experience health effects. The general public is less likely to be affected.';
    } else if (aqi <= 200) {
      return 'Unhealthy - Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects.';
    } else if (aqi <= 300) {
      return 'Very Unhealthy - Health alert: The risk of health effects is increased for everyone.';
    } else {
      return 'Hazardous - Health warning of emergency conditions: everyone is more likely to be affected.';
    }
  }

  List<String> _identifyFactors(
    int aqi,
    double pm25,
    double pm10,
    Map<String, dynamic> weatherData,
  ) {
    final factors = <String>[];

    // PM2.5 analysis
    if (pm25 > 35) {
      factors.add(
        'High PM2.5 levels (${pm25.toStringAsFixed(1)} µg/m³) - likely from vehicle emissions, industrial activity, or wildfires',
      );
    }

    // PM10 analysis
    if (pm10 > 50) {
      factors.add(
        'Elevated PM10 levels (${pm10.toStringAsFixed(1)} µg/m³) - possibly from dust, construction, or road traffic',
      );
    }

    // Weather factors
    final humidity = weatherData['humidity'] as double?;
    if (humidity != null && humidity > 80) {
      factors.add(
        'High humidity (${humidity.toStringAsFixed(0)}%) may trap pollutants near ground level',
      );
    }

    final windSpeed = weatherData['windSpeed'] as double?;
    if (windSpeed != null && windSpeed < 2) {
      factors.add(
        'Low wind speed (${windSpeed.toStringAsFixed(1)} m/s) reduces pollutant dispersion',
      );
    }

    if (factors.isEmpty) {
      factors.add('Current conditions are within normal ranges');
    }

    return factors;
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'analyze_aqi',
        description: 'Analyze AQI data and provide insights',
        schema: {
          'required': ['aqi', 'pm25', 'pm10'],
          'properties': {
            'aqi': {'type': 'integer'},
            'pm25': {'type': 'number'},
            'pm10': {'type': 'number'},
            'location': {'type': 'string'},
            'weatherData': {'type': 'object'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

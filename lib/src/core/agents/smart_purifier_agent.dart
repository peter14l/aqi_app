import '../agents/agent_base.dart';
import '../services/agent_logger.dart';

/// Smart Purifier Control Agent (Prototype)
/// Controls smart air purifiers based on AQI levels
class SmartPurifierAgent extends AgentBase {
  final AgentLogger _agentLogger = AgentLogger();

  // Simulated purifier state
  final Map<String, Map<String, dynamic>> _purifiers = {};

  SmartPurifierAgent() : super(name: 'SmartPurifierAgent');

  @override
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input) async {
    final startTime = DateTime.now();

    try {
      logInfo('Executing purifier command: $input');

      final action = input['action'] as String?;
      final purifierId = input['purifierId'] as String?;

      if (action == null) {
        throw ArgumentError('Action is required');
      }

      if (purifierId == null) {
        throw ArgumentError('Purifier ID is required');
      }

      Map<String, dynamic> result;

      switch (action) {
        case 'turn_on':
          result = await _turnOn(purifierId, input);
          break;
        case 'turn_off':
          result = await _turnOff(purifierId);
          break;
        case 'set_mode':
          result = await _setMode(purifierId, input);
          break;
        case 'get_status':
          result = await _getStatus(purifierId);
          break;
        case 'auto_adjust':
          result = await _autoAdjust(purifierId, input);
          break;
        default:
          throw ArgumentError('Unknown action: $action');
      }

      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: action,
        input: input,
        output: result,
        duration: duration,
      );

      return result;
    } catch (e, stackTrace) {
      logError('Purifier control failed', e, stackTrace);
      final duration = DateTime.now().difference(startTime);
      _agentLogger.logAgentExecution(
        agentName: name,
        action: 'purifier_control',
        input: input,
        error: e.toString(),
        duration: duration,
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _turnOn(
    String purifierId,
    Map<String, dynamic> input,
  ) async {
    // Safety check: Validate AQI before turning on
    final aqi = input['currentAqi'] as int? ?? 0;

    if (aqi < 0 || aqi > 500) {
      throw ArgumentError('Invalid AQI value for safety check');
    }

    _purifiers[purifierId] = {
      'status': 'on',
      'mode': 'auto',
      'fanSpeed': _calculateFanSpeed(aqi),
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    logInfo(
      'Turned on purifier $purifierId with fan speed ${_purifiers[purifierId]!['fanSpeed']}',
    );

    return {
      'success': true,
      'purifierId': purifierId,
      'status': 'on',
      'message': 'Purifier turned on successfully',
      ..._purifiers[purifierId]!,
    };
  }

  Future<Map<String, dynamic>> _turnOff(String purifierId) async {
    _purifiers[purifierId] = {
      'status': 'off',
      'mode': 'manual',
      'fanSpeed': 0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    logInfo('Turned off purifier $purifierId');

    return {
      'success': true,
      'purifierId': purifierId,
      'status': 'off',
      'message': 'Purifier turned off successfully',
    };
  }

  Future<Map<String, dynamic>> _setMode(
    String purifierId,
    Map<String, dynamic> input,
  ) async {
    final mode = input['mode'] as String?;

    if (mode == null || !['auto', 'manual', 'sleep', 'turbo'].contains(mode)) {
      throw ArgumentError(
        'Invalid mode. Must be: auto, manual, sleep, or turbo',
      );
    }

    final currentState = _purifiers[purifierId] ?? {};
    currentState['mode'] = mode;
    currentState['lastUpdated'] = DateTime.now().toIso8601String();

    _purifiers[purifierId] = currentState;

    logInfo('Set purifier $purifierId to $mode mode');

    return {
      'success': true,
      'purifierId': purifierId,
      'mode': mode,
      'message': 'Mode set successfully',
    };
  }

  Future<Map<String, dynamic>> _getStatus(String purifierId) async {
    final status = _purifiers[purifierId];

    if (status == null) {
      return {
        'success': false,
        'purifierId': purifierId,
        'message': 'Purifier not found',
      };
    }

    return {'success': true, 'purifierId': purifierId, ...status};
  }

  Future<Map<String, dynamic>> _autoAdjust(
    String purifierId,
    Map<String, dynamic> input,
  ) async {
    final aqi = input['currentAqi'] as int?;

    if (aqi == null) {
      throw ArgumentError('Current AQI is required for auto-adjust');
    }

    // Safety check
    if (aqi < 0 || aqi > 500) {
      throw ArgumentError('Invalid AQI value');
    }

    final fanSpeed = _calculateFanSpeed(aqi);
    final mode = _determineMode(aqi);

    _purifiers[purifierId] = {
      'status': 'on',
      'mode': mode,
      'fanSpeed': fanSpeed,
      'lastUpdated': DateTime.now().toIso8601String(),
      'autoAdjusted': true,
      'basedOnAqi': aqi,
    };

    logInfo(
      'Auto-adjusted purifier $purifierId: mode=$mode, fanSpeed=$fanSpeed (AQI=$aqi)',
    );

    return {
      'success': true,
      'purifierId': purifierId,
      'action': 'auto_adjusted',
      'aqi': aqi,
      'mode': mode,
      'fanSpeed': fanSpeed,
      'message': 'Purifier auto-adjusted based on current AQI',
    };
  }

  int _calculateFanSpeed(int aqi) {
    if (aqi <= 50) return 1; // Low speed for good air
    if (aqi <= 100) return 2; // Medium-low
    if (aqi <= 150) return 3; // Medium
    if (aqi <= 200) return 4; // Medium-high
    return 5; // Max speed for poor air
  }

  String _determineMode(int aqi) {
    if (aqi <= 50) return 'sleep'; // Quiet mode for good air
    if (aqi <= 100) return 'auto'; // Auto mode
    if (aqi <= 200) return 'turbo'; // Turbo for moderate-poor air
    return 'turbo'; // Max for very poor air
  }

  @override
  List<AgentTool> getTools() {
    return [
      AgentTool(
        name: 'control_purifier',
        description: 'Control smart air purifier',
        schema: {
          'required': ['action', 'purifierId'],
          'properties': {
            'action': {
              'type': 'string',
              'enum': [
                'turn_on',
                'turn_off',
                'set_mode',
                'get_status',
                'auto_adjust',
              ],
            },
            'purifierId': {'type': 'string'},
            'mode': {'type': 'string'},
            'currentAqi': {'type': 'integer'},
          },
        },
        execute: (params) => execute(params),
      ),
    ];
  }
}

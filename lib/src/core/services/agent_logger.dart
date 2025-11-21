import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// Logs agent activities, tool usage, and errors
class AgentLogger {
  static final AgentLogger _instance = AgentLogger._internal();
  factory AgentLogger() => _instance;
  
  AgentLogger._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  final List<AgentLogEntry> _logs = [];
  final _uuid = const Uuid();

  /// Log an agent execution
  String logAgentExecution({
    required String agentName,
    required String action,
    Map<String, dynamic>? input,
    Map<String, dynamic>? output,
    Duration? duration,
    String? error,
  }) {
    final id = _uuid.v4();
    final entry = AgentLogEntry(
      id: id,
      timestamp: DateTime.now(),
      agentName: agentName,
      action: action,
      input: input,
      output: output,
      duration: duration,
      error: error,
    );

    _logs.add(entry);
    
    if (error != null) {
      _logger.e('[$agentName] $action - ERROR: $error');
    } else {
      _logger.i('[$agentName] $action ${duration != null ? "(${duration.inMilliseconds}ms)" : ""}');
    }

    return id;
  }

  /// Log a tool usage
  void logToolUsage({
    required String toolName,
    required Map<String, dynamic> params,
    dynamic result,
    String? error,
  }) {
    if (error != null) {
      _logger.e('Tool: $toolName - ERROR: $error');
    } else {
      _logger.d('Tool: $toolName - Success');
    }
  }

  /// Log API call
  void logApiCall({
    required String apiName,
    required String endpoint,
    int? statusCode,
    Duration? duration,
    String? error,
  }) {
    if (error != null) {
      _logger.e('API: $apiName ($endpoint) - ERROR: $error');
    } else {
      _logger.i('API: $apiName ($endpoint) - $statusCode ${duration != null ? "(${duration.inMilliseconds}ms)" : ""}');
    }
  }

  /// Get all logs
  List<AgentLogEntry> getLogs() => List.unmodifiable(_logs);

  /// Get logs for a specific agent
  List<AgentLogEntry> getLogsForAgent(String agentName) {
    return _logs.where((log) => log.agentName == agentName).toList();
  }

  /// Get error logs
  List<AgentLogEntry> getErrorLogs() {
    return _logs.where((log) => log.error != null).toList();
  }

  /// Clear all logs
  void clearLogs() {
    _logs.clear();
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final totalExecutions = _logs.length;
    final errors = _logs.where((log) => log.error != null).length;
    final avgDuration = _logs
        .where((log) => log.duration != null)
        .map((log) => log.duration!.inMilliseconds)
        .fold<int>(0, (sum, duration) => sum + duration) / 
        _logs.where((log) => log.duration != null).length;

    final agentCounts = <String, int>{};
    for (final log in _logs) {
      agentCounts[log.agentName] = (agentCounts[log.agentName] ?? 0) + 1;
    }

    return {
      'totalExecutions': totalExecutions,
      'errors': errors,
      'errorRate': totalExecutions > 0 ? errors / totalExecutions : 0,
      'avgDurationMs': avgDuration.isNaN ? 0 : avgDuration,
      'agentCounts': agentCounts,
    };
  }
}

/// Represents a single log entry
class AgentLogEntry {
  final String id;
  final DateTime timestamp;
  final String agentName;
  final String action;
  final Map<String, dynamic>? input;
  final Map<String, dynamic>? output;
  final Duration? duration;
  final String? error;

  AgentLogEntry({
    required this.id,
    required this.timestamp,
    required this.agentName,
    required this.action,
    this.input,
    this.output,
    this.duration,
    this.error,
  });

  bool get hasError => error != null;
}

import 'package:logger/logger.dart';

/// Base class for all agents in the multi-agent system
abstract class AgentBase {
  final String name;
  final Logger logger;

  AgentBase({required this.name})
    : logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 80,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      );

  /// Execute the agent's primary function
  /// Returns a map containing the result and any metadata
  Future<Map<String, dynamic>> execute(Map<String, dynamic> input);

  /// Get the agent's name
  String getName() => name;

  /// Get the list of tools this agent can use
  List<AgentTool> getTools();

  /// Log agent activity
  void logInfo(String message) {
    logger.i('[$name] $message');
  }

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e('[$name] $message', error: error, stackTrace: stackTrace);
  }

  void logWarning(String message) {
    logger.w('[$name] $message');
  }

  void logDebug(String message) {
    logger.d('[$name] $message');
  }
}

/// Represents a tool that an agent can use
class AgentTool {
  final String name;
  final String description;
  final Map<String, dynamic> schema;
  final Future<dynamic> Function(Map<String, dynamic> params) execute;

  AgentTool({
    required this.name,
    required this.description,
    required this.schema,
    required this.execute,
  });

  /// Validate input parameters against schema
  bool validateParams(Map<String, dynamic> params) {
    final required = schema['required'] as List<String>? ?? [];
    for (final key in required) {
      if (!params.containsKey(key)) {
        return false;
      }
    }
    return true;
  }
}

/// Agent Communication Protocol
///
/// This file defines the communication infrastructure for the multi-agent system.
/// Agents communicate through a standardized message format and event system.

import 'dart:async';
import 'package:logger/logger.dart';

/// Message types for agent communication
enum MessageType { request, response, event, error }

/// Agent message structure
class AgentMessage {
  final String id;
  final String fromAgent;
  final String toAgent;
  final MessageType type;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final String? correlationId;

  AgentMessage({
    required this.id,
    required this.fromAgent,
    required this.toAgent,
    required this.type,
    required this.payload,
    DateTime? timestamp,
    this.correlationId,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromAgent': fromAgent,
    'toAgent': toAgent,
    'type': type.toString(),
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
    'correlationId': correlationId,
  };
}

/// Event bus for agent communication
class AgentEventBus {
  static final AgentEventBus _instance = AgentEventBus._internal();
  factory AgentEventBus() => _instance;

  AgentEventBus._internal();

  final _controller = StreamController<AgentMessage>.broadcast();
  final Logger _logger = Logger();

  /// Stream of all agent messages
  Stream<AgentMessage> get messages => _controller.stream;

  /// Publish a message to the event bus
  void publish(AgentMessage message) {
    _logger.d('Publishing message: ${message.fromAgent} -> ${message.toAgent}');
    _controller.add(message);
  }

  /// Subscribe to messages for a specific agent
  Stream<AgentMessage> subscribe(String agentName) {
    return messages.where((msg) => msg.toAgent == agentName);
  }

  /// Subscribe to specific message types
  Stream<AgentMessage> subscribeToType(MessageType type) {
    return messages.where((msg) => msg.type == type);
  }

  /// Close the event bus
  void dispose() {
    _controller.close();
  }
}

/// Agent registry for tracking active agents
class AgentRegistry {
  static final AgentRegistry _instance = AgentRegistry._internal();
  factory AgentRegistry() => _instance;

  AgentRegistry._internal();

  final Map<String, AgentInfo> _agents = {};
  final Logger _logger = Logger();

  /// Register an agent
  void register(String name, String type, {Map<String, dynamic>? metadata}) {
    _agents[name] = AgentInfo(
      name: name,
      type: type,
      status: AgentStatus.active,
      registeredAt: DateTime.now(),
      metadata: metadata ?? {},
    );
    _logger.i('Registered agent: $name ($type)');
  }

  /// Unregister an agent
  void unregister(String name) {
    _agents.remove(name);
    _logger.i('Unregistered agent: $name');
  }

  /// Get agent info
  AgentInfo? getAgent(String name) => _agents[name];

  /// Get all active agents
  List<AgentInfo> getActiveAgents() {
    return _agents.values
        .where((agent) => agent.status == AgentStatus.active)
        .toList();
  }

  /// Update agent status
  void updateStatus(String name, AgentStatus status) {
    final agent = _agents[name];
    if (agent != null) {
      _agents[name] = agent.copyWith(status: status);
    }
  }
}

/// Agent information
class AgentInfo {
  final String name;
  final String type;
  final AgentStatus status;
  final DateTime registeredAt;
  final Map<String, dynamic> metadata;

  AgentInfo({
    required this.name,
    required this.type,
    required this.status,
    required this.registeredAt,
    required this.metadata,
  });

  AgentInfo copyWith({
    String? name,
    String? type,
    AgentStatus? status,
    DateTime? registeredAt,
    Map<String, dynamic>? metadata,
  }) {
    return AgentInfo(
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      registeredAt: registeredAt ?? this.registeredAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Agent status
enum AgentStatus { active, busy, idle, error, offline }

/// Helper for sending messages between agents
class AgentCommunicator {
  final String agentName;
  final AgentEventBus _eventBus = AgentEventBus();
  final Logger _logger = Logger();

  AgentCommunicator(this.agentName);

  /// Send a request to another agent
  Future<Map<String, dynamic>> sendRequest(
    String toAgent,
    Map<String, dynamic> payload, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final message = AgentMessage(
      id: messageId,
      fromAgent: agentName,
      toAgent: toAgent,
      type: MessageType.request,
      payload: payload,
    );

    _eventBus.publish(message);
    _logger.d('Sent request from $agentName to $toAgent');

    // Wait for response (simplified - in production use proper async handling)
    return payload; // Placeholder
  }

  /// Send a response
  void sendResponse(
    String toAgent,
    Map<String, dynamic> payload,
    String correlationId,
  ) {
    final message = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromAgent: agentName,
      toAgent: toAgent,
      type: MessageType.response,
      payload: payload,
      correlationId: correlationId,
    );

    _eventBus.publish(message);
    _logger.d('Sent response from $agentName to $toAgent');
  }

  /// Broadcast an event
  void broadcastEvent(String eventType, Map<String, dynamic> data) {
    final message = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromAgent: agentName,
      toAgent: 'broadcast',
      type: MessageType.event,
      payload: {'eventType': eventType, ...data},
    );

    _eventBus.publish(message);
    _logger.d('Broadcast event from $agentName: $eventType');
  }
}

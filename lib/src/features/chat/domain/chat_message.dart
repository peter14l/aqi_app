class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? agentName;
  final double? confidence;
  final Map<String, dynamic>? data;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.agentName,
    this.confidence,
    this.data,
    this.isError = false,
  });
}
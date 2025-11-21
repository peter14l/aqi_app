import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants/app_colors.dart';
import '../../../core/providers/agent_providers.dart';
import '../../../core/services/agent_logger.dart';
import '../domain/chat_message.dart';
import 'widgets/agent_activity_monitor.dart';
import '../../theme/theme_provider.dart';
import '../../debug/presentation/agent_debug_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _activeAgent;
  String? _agentStatus;
  DateTime? _processingStartTime;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
      _processingStartTime = DateTime.now();
      _activeAgent = 'OrchestratorAgent';
      _agentStatus = 'Routing query...';
    });

    _controller.clear();
    _scrollToBottom();

    try {
      // Update status: Fetching data
      setState(() {
        _activeAgent = 'DataFetchAgent';
        _agentStatus = 'Fetching real-time AQI data...';
      });

      final orchestrator = await ref.read(orchestratorAgentProvider.future);

      // Update status: Analyzing
      setState(() {
        _activeAgent = 'AnalysisAgent';
        _agentStatus = 'Analyzing air quality data...';
      });

      final response = await orchestrator.execute({
        'query': text,
        'lat': 50.0647,
        'lon': 19.9450,
      });

      // Update status: Generating response
      setState(() {
        _activeAgent = 'AdvisoryAgent';
        _agentStatus = 'Generating recommendations...';
      });

      final formattedResponse = _formatResponse(response);
      final queryType = response['queryType'] as String?;

      setState(() {
        _messages.add(
          ChatMessage(
            text: formattedResponse,
            isUser: false,
            timestamp: DateTime.now(),
            data: response,
            agentName: _getAgentForQueryType(queryType),
            confidence: _getConfidence(response),
          ),
        );
        _isLoading = false;
        _activeAgent = null;
        _agentStatus = null;
      });

      _scrollToBottom();

      final memoryAgent = ref.read(memoryAgentProvider);
      await memoryAgent.execute({
        'action': 'save_query',
        'query': text,
        'response': response,
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'SYSTEM ERROR: ${e.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
        _isLoading = false;
        _activeAgent = null;
        _agentStatus = null;
      });
    }
  }

  String _getAgentForQueryType(String? queryType) {
    switch (queryType) {
      case 'prediction':
        return 'PredictionAgent';
      case 'recommendation':
        return 'AdvisoryAgent';
      case 'simulation':
        return 'SimulationAgent';
      case 'current_status':
        return 'AnalysisAgent';
      default:
        return 'OrchestratorAgent';
    }
  }

  double? _getConfidence(Map<String, dynamic> response) {
    final predictions = response['predictions'] as Map<String, dynamic>?;
    if (predictions != null) {
      return (predictions['confidence'] as num?)?.toDouble();
    }
    return null;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatResponse(Map<String, dynamic> response) {
    final queryType = response['queryType'] as String?;

    switch (queryType) {
      case 'current_status':
        final data = response['data'] as Map<String, dynamic>?;
        final analysis = response['analysis'] as Map<String, dynamic>?;
        final aqi = data?['aqi'] ?? 0;
        final location = data?['location'] ?? 'Unknown';
        final analysisText = analysis?['analysis'] ?? '';
        return '📍 LOCATION: $location\n🌡️ AQI: $aqi\n\n$analysisText';

      case 'prediction':
        final predictions = response['predictions'] as Map<String, dynamic>?;
        final predList = predictions?['predictions'] as List? ?? [];
        final confidence = predictions?['confidence'] ?? 0.0;

        if (predList.isEmpty) {
          return '⚠️ Unable to generate predictions';
        }

        final next24h = predList.take(24).toList();
        final avgAqi =
            next24h.map((p) => p['aqi'] as int).reduce((a, b) => a + b) /
            next24h.length;

        return '📊 24-HOUR FORECAST\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'Average AQI: ${avgAqi.round()}\n'
            'Confidence: ${(confidence * 100).round()}%\n\n'
            'Next 6 hours:\n${next24h.take(6).map((p) => '${p['hour']}h → ${p['aqi']} (${p['status']})').join('\n')}';

      case 'recommendation':
        final recommendations =
            response['recommendations'] as Map<String, dynamic>?;
        final recList = recommendations?['recommendations'] as List? ?? [];
        final riskLevel = recommendations?['riskLevel'] ?? 'Unknown';

        return '⚠️ RISK LEVEL: $riskLevel\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            'RECOMMENDATIONS:\n${recList.map((r) => '• $r').join('\n')}';

      case 'simulation':
        final simulation = response['simulation'] as Map<String, dynamic>?;
        final simResult = simulation?['simulation'] as Map<String, dynamic>?;
        final healthImpact = simResult?['healthImpact'] ?? '';
        final recommendations = simResult?['recommendations'] as List? ?? [];

        return '🔮 SIMULATION RESULTS\n'
            '━━━━━━━━━━━━━━━━━━━━\n'
            '$healthImpact\n\n'
            'RECOMMENDATIONS:\n${recommendations.map((r) => '• $r').join('\n')}';

      default:
        return response.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.grey[50];
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'AI ASSISTANT',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AgentDebugScreen(),
                ),
              );
            },
            tooltip: 'Behind the Scenes',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: textColor),
            onPressed: () {
              setState(() {
                _messages.clear();
              });
            },
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Agent Activity Monitor
          if (_isLoading && _activeAgent != null)
            AgentActivityMonitor(
              activeAgent: _activeAgent,
              status: _agentStatus,
              processingTime:
                  _processingStartTime != null
                      ? DateTime.now().difference(_processingStartTime!)
                      : null,
              isProcessing: true,
            ),
          Expanded(
            child:
                _messages.isEmpty
                    ? _buildEmptyState(isDarkMode)
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _ChatBubble(
                          message: _messages[index],
                          isDarkMode: isDarkMode,
                        );
                      },
                    ),
          ),
          if (_isLoading) _buildLoadingIndicator(isDarkMode),
          _buildInputArea(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final iconColor =
        isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.1),
            ),
            child: Icon(Icons.chat_bubble_outline, size: 40, color: iconColor),
          ),
          const SizedBox(height: 24),
          Text(
            'ASK ME ANYTHING',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'About air quality, predictions, or recommendations',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _SuggestionChip(
                label: 'Current AQI?',
                onTap: () => _sendMessage('What\'s the current AQI?'),
                isDarkMode: isDarkMode,
              ),
              _SuggestionChip(
                label: 'Go for a run?',
                onTap: () => _sendMessage('Should I go for a run?'),
                isDarkMode: isDarkMode,
              ),
              _SuggestionChip(
                label: 'Tomorrow\'s forecast?',
                onTap: () => _sendMessage('What will AQI be tomorrow?'),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDarkMode) {
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'PROCESSING...',
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDarkMode) {
    final bgColor = isDarkMode ? AppColors.darkCard : Colors.white;
    final borderColor =
        isDarkMode
            ? AppColors.neonCyan.withOpacity(0.3)
            : AppColors.textPrimaryDark.withOpacity(0.1);
    final inputBgColor =
        isDarkMode
            ? AppColors.darkBackground
            : AppColors.textPrimaryDark.withOpacity(0.05);
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _controller,
                style: GoogleFonts.outfit(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Ask about air quality...',
                  hintStyle: GoogleFonts.outfit(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_controller.text),
              icon: Icon(
                Icons.send,
                color: isDarkMode ? AppColors.darkBackground : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;

  const _ChatBubble({required this.message, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final userBubbleColor =
        isDarkMode
            ? AppColors.neonCyan.withOpacity(0.2)
            : AppColors.textPrimaryDark;
    final botBubbleColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;
    final userTextColor = isDarkMode ? AppColors.textPrimary : Colors.white;
    final botTextColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                message.isUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser)
                message.agentName != null
                    ? AgentAvatar(agentName: message.agentName!, size: 36)
                    : _buildAvatar(false, isDarkMode),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      message.isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    // Agent name for bot messages
                    if (!message.isUser && message.agentName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          message.agentName!,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            message.isUser ? userBubbleColor : botBubbleColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            message.isError
                                ? Border.all(color: AppColors.error, width: 1)
                                : (isDarkMode && message.isUser
                                    ? Border.all(
                                      color: AppColors.neonCyan.withOpacity(
                                        0.5,
                                      ),
                                    )
                                    : null),
                      ),
                      child: Text(
                        message.text,
                        style: GoogleFonts.outfit(
                          color:
                              message.isUser
                                  ? userTextColor
                                  : message.isError
                                  ? AppColors.error
                                  : botTextColor,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    // Confidence badge for predictions
                    if (!message.isUser && message.confidence != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ConfidenceBadge(confidence: message.confidence!),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (message.isUser) _buildAvatar(true, isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser, bool isDarkMode) {
    final bgColor =
        isUser
            ? (isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark)
            : (isDarkMode
                ? AppColors.neonCyan.withOpacity(0.1)
                : AppColors.textPrimaryDark.withOpacity(0.1));
    final iconColor =
        isUser
            ? (isDarkMode ? AppColors.darkBackground : Colors.white)
            : (isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: iconColor,
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDarkMode;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDarkMode
            ? AppColors.neonCyan.withOpacity(0.1)
            : AppColors.textPrimaryDark.withOpacity(0.05);
    final textColor =
        isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border:
              isDarkMode
                  ? Border.all(color: AppColors.neonCyan.withOpacity(0.3))
                  : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

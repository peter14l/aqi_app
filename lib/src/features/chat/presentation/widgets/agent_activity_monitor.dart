import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';

/// Widget that displays which AI agent is currently processing
class AgentActivityMonitor extends StatelessWidget {
  final String? activeAgent;
  final String? status;
  final Duration? processingTime;
  final bool isProcessing;

  const AgentActivityMonitor({
    super.key,
    this.activeAgent,
    this.status,
    this.processingTime,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isProcessing && activeAgent == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Animated indicator
          if (isProcessing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              ),
            )
          else
            Icon(
              Icons.check_circle,
              color: AppColors.neonCyan,
              size: 20,
            ),
          const SizedBox(width: 12),

          // Agent info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _getAgentIcon(activeAgent),
                    const SizedBox(width: 8),
                    Text(
                      activeAgent ?? 'Processing',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                if (status != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    status!,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Processing time
          if (processingTime != null)
            Text(
              '${processingTime!.inMilliseconds}ms',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _getAgentIcon(String? agent) {
    IconData icon;
    switch (agent?.toLowerCase()) {
      case 'datafetchagent':
        icon = Icons.cloud_download;
        break;
      case 'analysisagent':
        icon = Icons.psychology;
        break;
      case 'advisoryagent':
        icon = Icons.lightbulb;
        break;
      case 'predictionagent':
        icon = Icons.trending_up;
        break;
      case 'simulationagent':
        icon = Icons.science;
        break;
      case 'routeexposureagent':
        icon = Icons.route;
        break;
      case 'memoryagent':
        icon = Icons.storage;
        break;
      case 'orchestratoragent':
        icon = Icons.hub;
        break;
      case 'smartpurifieragent':
        icon = Icons.air;
        break;
      default:
        icon = Icons.smart_toy;
    }
    return Icon(icon, size: 16, color: AppColors.neonCyan);
  }
}

/// Confidence score badge for predictions
class ConfidenceBadge extends StatelessWidget {
  final double confidence; // 0.0 to 1.0
  final bool showPercentage;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).round();
    final color = _getConfidenceColor(confidence);
    final label = _getConfidenceLabel(confidence);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getConfidenceIcon(confidence),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            showPercentage ? '$percentage%' : label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return Colors.green;
    } else if (confidence >= 0.6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.8) {
      return 'High';
    } else if (confidence >= 0.6) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) {
      return Icons.verified;
    } else if (confidence >= 0.6) {
      return Icons.info;
    } else {
      return Icons.warning;
    }
  }
}

/// Agent avatar with animation
class AgentAvatar extends StatelessWidget {
  final String agentName;
  final bool isActive;
  final double size;

  const AgentAvatar({
    super.key,
    required this.agentName,
    this.isActive = false,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getAgentIcon(agentName);
    final color = isActive ? AppColors.neonCyan : AppColors.textTertiary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(isActive ? 0.5 : 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              size: size * 0.5,
              color: color,
            ),
          ),
          if (isActive)
            Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getAgentIcon(String agent) {
    switch (agent.toLowerCase()) {
      case 'datafetchagent':
        return Icons.cloud_download;
      case 'analysisagent':
        return Icons.psychology;
      case 'advisoryagent':
        return Icons.lightbulb;
      case 'predictionagent':
        return Icons.trending_up;
      case 'simulationagent':
        return Icons.science;
      case 'routeexposureagent':
        return Icons.route;
      case 'memoryagent':
        return Icons.storage;
      case 'orchestratoragent':
        return Icons.hub;
      case 'smartpurifieragent':
        return Icons.air;
      default:
        return Icons.smart_toy;
    }
  }
}

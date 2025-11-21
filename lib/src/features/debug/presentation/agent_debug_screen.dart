import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../core/services/agent_logger.dart';
import '../../../core/demo/demo_mode_provider.dart';

/// Screen showing behind-the-scenes agent activity
class AgentDebugScreen extends ConsumerWidget {
  const AgentDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentLogger = AgentLogger();
    final logs = agentLogger.getLogs();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Behind the Scenes',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Demo Mode Card
            _buildDemoModeCard(ref),
            const SizedBox(height: 24),

            // System Architecture Card
            _buildArchitectureCard(),
            const SizedBox(height: 24),

            // Agent Status Cards
            _buildAgentStatusSection(),
            const SizedBox(height: 24),

            // Recent Activity Logs
            _buildActivityLogsSection(logs),
          ],
        ),
      ),
    );
  }

  Widget _buildArchitectureCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.architecture, color: AppColors.neonCyan, size: 24),
              const SizedBox(width: 12),
              Text(
                'Multi-Agent System',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '9 specialized AI agents working together to provide intelligent air quality insights',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAgentChip('Orchestrator', Icons.hub),
              _buildAgentChip('DataFetch', Icons.cloud_download),
              _buildAgentChip('Analysis', Icons.psychology),
              _buildAgentChip('Advisory', Icons.lightbulb),
              _buildAgentChip('Prediction', Icons.trending_up),
              _buildAgentChip('Simulation', Icons.science),
              _buildAgentChip('RouteExposure', Icons.route),
              _buildAgentChip('Memory', Icons.storage),
              _buildAgentChip('SmartPurifier', Icons.air),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentChip(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.neonCyan),
          const SizedBox(width: 6),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.neonCyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent Status',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildAgentStatusCard('OrchestratorAgent', 'Ready', true),
        const SizedBox(height: 8),
        _buildAgentStatusCard('DataFetchAgent', 'Ready', true),
        const SizedBox(height: 8),
        _buildAgentStatusCard('AnalysisAgent', 'Ready', true),
        const SizedBox(height: 8),
        _buildAgentStatusCard('AdvisoryAgent', 'Ready', true),
      ],
    );
  }

  Widget _buildAgentStatusCard(String name, String status, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            status,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogsSection(List<AgentLogEntry> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (logs.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No activity yet. Start chatting to see agent logs!',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...logs
              .take(10)
              .map(
                (log) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildLogCard(log),
                ),
              ),
      ],
    );
  }

  Widget _buildLogCard(AgentLogEntry log) {
    final agentName = log.agentName;
    final action = log.action;
    final duration = log.duration;
    final error = log.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border:
            error != null
                ? Border.all(color: AppColors.error.withOpacity(0.5), width: 1)
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                error != null ? Icons.error : Icons.check_circle,
                size: 16,
                color: error != null ? AppColors.error : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  agentName,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (duration != null)
                Text(
                  '${duration.inMilliseconds}ms',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            action,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 4),
            Text(
              'Error: $error',
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDemoModeCard(WidgetRef ref) {
    final isDemoMode = ref.watch(demoModeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonCyan, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.science, color: AppColors.neonCyan, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Mode',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Use simulated data for presentation',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDemoMode,
            onChanged:
                (value) => ref.read(demoModeProvider.notifier).toggleDemoMode(),
            activeColor: AppColors.neonCyan,
          ),
        ],
      ),
    );
  }
}

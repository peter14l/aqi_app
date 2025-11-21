import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/providers/agent_providers.dart';

class RecommendationsCard extends ConsumerWidget {
  final String activity;

  const RecommendationsCard({super.key, this.activity = 'general'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider(activity));

    return recommendationsAsync.when(
      data: (data) {
        final recommendations =
            data['recommendations'] as Map<String, dynamic>?;
        final recList = recommendations?['recommendations'] as List? ?? [];
        final riskLevel = recommendations?['riskLevel'] as String? ?? '';
        final actions = recommendations?['actions'] as List? ?? [];

        if (recList.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.greenText.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.recommend_outlined,
                    color: AppColors.greenText,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recommendations',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenText,
                    ),
                  ),
                ],
              ),
              if (riskLevel.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(riskLevel).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Risk Level: $riskLevel',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getRiskColor(riskLevel),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ...recList.asMap().entries.map((entry) {
                final index = entry.key;
                final rec = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.greenText.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rec.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: AppColors.greenText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(color: AppColors.greenText, height: 1),
                const SizedBox(height: 12),
                Text(
                  'Action Items:',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenText,
                  ),
                ),
                const SizedBox(height: 8),
                ...actions.map((action) {
                  final actionMap = action as Map<String, dynamic>;
                  final actionText = actionMap['action'] as String;
                  final priority = actionMap['priority'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(
                          _getPriorityIcon(priority),
                          size: 16,
                          color: _getPriorityColor(priority),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            actionText,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AppColors.greenText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
      loading:
          () => Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.greenText,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generating recommendations...',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.greenText.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('Low')) return Colors.green;
    if (riskLevel.contains('Moderate')) return Colors.orange;
    if (riskLevel.contains('High')) return Colors.red;
    if (riskLevel.contains('Extreme')) return Colors.purple;
    return AppColors.greenText;
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }
}

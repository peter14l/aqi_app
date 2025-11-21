import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/providers/agent_providers.dart';

class InsightsCard extends ConsumerWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(currentAqiWithAnalysisProvider);

    return analysisAsync.when(
      data: (data) {
        final analysis = data['analysis'] as Map<String, dynamic>?;
        final analysisText = analysis?['analysis'] as String? ?? '';
        final healthImpact = analysis?['healthImpact'] as String? ?? '';
        final factors = analysis?['contributingFactors'] as List? ?? [];

        if (analysisText.isEmpty && healthImpact.isEmpty) {
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
                    Icons.lightbulb_outline,
                    color: AppColors.greenText,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Insights',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (analysisText.isNotEmpty) ...[
                Text(
                  analysisText,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: AppColors.greenText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (healthImpact.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        color: AppColors.greenText,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          healthImpact,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppColors.greenText,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (factors.isNotEmpty) ...[
                Text(
                  'Contributing Factors:',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greenText,
                  ),
                ),
                const SizedBox(height: 8),
                ...factors.map(
                  (factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: AppColors.greenText,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            factor.toString(),
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: AppColors.greenText,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                  'Analyzing air quality...',
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../constants/app_colors.dart';
import '../../../theme/theme_provider.dart';

class InfoCard extends ConsumerWidget {
  final String title;
  final String value;
  final String unit;
  final String footer;
  final IconData? icon;
  final Widget? customContent;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = '',
    this.footer = '',
    this.icon,
    this.customContent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode ? AppColors.darkCard : Colors.white.withOpacity(0.8);
    final labelColor = AppColors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: labelColor),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (customContent != null)
            Expanded(child: customContent!)
          else ...[
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              footer,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

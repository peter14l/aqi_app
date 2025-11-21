import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../aqi/presentation/aqi_controller.dart';
import '../../theme/theme_provider.dart';
import '../data/habits_repository.dart';
import '../../achievements/presentation/widgets/achievement_badge.dart';
import '../../achievements/data/achievements_repository.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final aqiAsync = ref.watch(aqiControllerProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    final backgroundColor =
        isDarkMode ? AppColors.darkBackground : Colors.grey[50];
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final cardColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Habits & Exposure',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exposure Summary
            aqiAsync.when(
              data: (aqi) => _ExposureSummary(currentPm25: aqi.pm25),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 32),

            // Achievements Section
            Text(
              'Achievements',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: FutureBuilder(
                future: AchievementsRepository().getAllAchievements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No achievements found',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }
                  final achievements = snapshot.data!;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: achievements.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 300,
                        child: AchievementBadge(
                          achievement: achievements[index],
                          showProgress: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Your Daily Habits',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Habits List
            Expanded(
              child: habitsAsync.when(
                data:
                    (habits) => ListView.builder(
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      habit.isOutdoor
                                          ? AppColors.aqiOrangeBackground
                                              .withOpacity(0.3)
                                          : AppColors.aqiGreenBackground
                                              .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  habit.isOutdoor
                                      ? Icons.directions_walk
                                      : Icons.home,
                                  color: textColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      habit.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${habit.durationMinutes} mins • ${habit.timeOfDay}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      habit.isOutdoor
                                          ? AppColors.aqiOrangeBackground
                                          : AppColors.aqiGreenBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  habit.isOutdoor ? 'Outdoor' : 'Indoor',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        AppColors
                                            .textPrimaryDark, // Keep dark text on badges
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context, ref),
        backgroundColor:
            isDarkMode ? AppColors.neonCyan : AppColors.textPrimaryDark,
        child: Icon(
          Icons.add,
          color: isDarkMode ? AppColors.darkBackground : Colors.white,
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    bool isOutdoor = false;
    final isDarkMode = ref.read(isDarkModeProvider);
    final dialogBgColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: dialogBgColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(
                  'Add New Habit',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        labelStyle: TextStyle(color: AppColors.textTertiary),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textTertiary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: textColor),
                        ),
                      ),
                      style: GoogleFonts.outfit(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'Duration (minutes)',
                        labelStyle: TextStyle(color: AppColors.textTertiary),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.textTertiary),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: textColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Outdoor?',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: isOutdoor,
                          onChanged: (val) => setState(() => isOutdoor = val),
                          activeColor:
                              isDarkMode
                                  ? AppColors.neonCyan
                                  : AppColors.textPrimaryDark,
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.outfit(color: AppColors.textTertiary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          durationController.text.isNotEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Habit added (Mock)')),
                        );
                      }
                    },
                    child: Text(
                      'Add',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode
                                ? AppColors.neonCyan
                                : AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _ExposureSummary extends ConsumerWidget {
  final double currentPm25;

  const _ExposureSummary({required this.currentPm25});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exposureAsync = ref.watch(exposureProvider(currentPm25));
    final isDarkMode = ref.watch(isDarkModeProvider);
    final cardColor =
        isDarkMode ? AppColors.darkCard : AppColors.particulatesCardBackground;
    final textColor =
        isDarkMode ? AppColors.textPrimary : AppColors.textPrimaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: exposureAsync.when(
        data:
            (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTIMATED DAILY EXPOSURE',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${data.dailyExposure.toStringAsFixed(1)} µg',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.aqiGreenBackground.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color:
                            isDarkMode
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryDark,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          data.recommendation,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color:
                                isDarkMode
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => const Text('Error calculating exposure'),
      ),
    );
  }
}

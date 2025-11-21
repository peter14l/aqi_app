import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../constants/app_colors.dart';

/// Service for sharing AQI data and insights
class ShareService {
  /// Share AQI as text
  static Future<void> shareAqiText({
    required int aqi,
    required String status,
    required String location,
  }) async {
    final text = '''
🌍 Air Quality Update

Location: $location
AQI: $aqi ($status)

Shared via AQI Assistant - Your AI-powered air quality companion
''';

    await Share.share(text);
  }

  /// Share insight as text
  static Future<void> shareInsight({
    required String title,
    required String message,
  }) async {
    final text = '''
💡 $title

$message

Shared via AQI Assistant - Powered by Multi-Agent AI
''';

    await Share.share(text);
  }

  /// Generate and share AQI card image
  static Future<void> shareAqiCard({
    required GlobalKey cardKey,
    required String filename,
  }) async {
    try {
      // Capture widget as image
      final boundary =
          cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) return;

      // Save to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename.png');
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out my air quality stats! 🌍\n\nShared via AQI Assistant',
      );
    } catch (e) {
      debugPrint('Error sharing card: $e');
    }
  }
}

/// Shareable AQI card widget
class ShareableAqiCard extends StatelessWidget {
  final int aqi;
  final String status;
  final String location;
  final Color color;
  final String? insight;

  const ShareableAqiCard({
    super.key,
    required this.aqi,
    required this.status,
    required this.location,
    required this.color,
    this.insight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBackground,
            AppColors.darkBackground.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.air, color: AppColors.neonCyan, size: 32),
              const SizedBox(width: 12),
              Text(
                'AQI Assistant',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // AQI Circle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.5), width: 3),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$aqi',
                    style: GoogleFonts.outfit(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: AppColors.textTertiary, size: 16),
              const SizedBox(width: 4),
              Text(
                location,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          // Insight
          if (insight != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                insight!,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Footer
          Text(
            'Powered by Multi-Agent AI',
            style: GoogleFonts.outfit(fontSize: 12, color: AppColors.neonCyan),
          ),
        ],
      ),
    );
  }
}

/// Shareable insight card widget
class ShareableInsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final IconData icon;

  const ShareableInsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonCyan.withOpacity(0.1),
            AppColors.darkBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonCyan.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCyan,
                  AppColors.neonCyan.withOpacity(0.6),
                ],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Value
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.neonCyan,
            ),
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            description,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.air, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'AQI Assistant',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

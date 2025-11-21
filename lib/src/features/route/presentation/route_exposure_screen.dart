import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../core/providers/agent_providers.dart';

class RouteExposureScreen extends ConsumerStatefulWidget {
  const RouteExposureScreen({super.key});

  @override
  ConsumerState<RouteExposureScreen> createState() =>
      _RouteExposureScreenState();
}

class _RouteExposureScreenState extends ConsumerState<RouteExposureScreen> {
  Map<String, dynamic>? _exposureData;
  bool _isLoading = false;

  Future<void> _calculateExposure() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final routeAgent = ref.read(routeExposureAgentProvider);
      final dataFetchAgent = ref.read(dataFetchAgentProvider);

      // Fetch current AQI
      final aqiData = await dataFetchAgent.execute({
        'action': 'realtime_aqi',
        'lat': 50.0647,
        'lon': 19.9450,
      });

      // Calculate route exposure
      final result = await routeAgent.execute({
        'route': [
          {'lat': 50.0647, 'lon': 19.9450},
          {'lat': 50.0700, 'lon': 19.9500},
        ],
        'aqiData': {...aqiData, 'durationMinutes': 30},
      });

      setState(() {
        _exposureData = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating exposure: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Route Exposure',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyze PM Exposure on Your Route',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.greenText,
              ),
            ),
            const SizedBox(height: 20),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calculateExposure,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenText,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          'Calculate Exposure',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 30),

            // Results
            if (_exposureData != null) ...[
              _buildExposureCard(),
              const SizedBox(height: 20),
              _buildScoreCard(),
              const SizedBox(height: 20),
              _buildSuggestionsCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExposureCard() {
    final exposure = _exposureData!['exposure'] as Map<String, dynamic>;

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
          Text(
            'Exposure Analysis',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greenText,
            ),
          ),
          const SizedBox(height: 16),
          _buildExposureRow(
            'PM2.5 Exposure',
            '${exposure['pm25Exposure'].toStringAsFixed(1)} µg/m³·h',
          ),
          _buildExposureRow(
            'PM10 Exposure',
            '${exposure['pm10Exposure'].toStringAsFixed(1)} µg/m³·h',
          ),
          _buildExposureRow(
            'Total Exposure',
            '${exposure['totalExposure'].toStringAsFixed(1)} µg/m³·h',
          ),
          _buildExposureRow(
            'Duration',
            '${exposure['durationMinutes']} minutes',
          ),
          _buildExposureRow('Average AQI', '${exposure['averageAqi']}'),
        ],
      ),
    );
  }

  Widget _buildExposureRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: AppColors.greenText.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greenText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final score = _exposureData!['score'] as Map<String, dynamic>;
    final rating = score['rating'] as String;
    final scoreValue = score['score'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getRatingColor(rating).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getRatingColor(rating).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            'Route Score',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: AppColors.greenText,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$scoreValue',
            style: GoogleFonts.montserrat(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getRatingColor(rating),
            ),
          ),
          Text(
            rating,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _getRatingColor(rating),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            score['healthImpact'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: AppColors.greenText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard() {
    final suggestions = _exposureData!['suggestions'] as List;

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
          Text(
            'Suggestions',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greenText,
            ),
          ),
          const SizedBox(height: 16),
          ...suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: AppColors.greenText,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      suggestion.toString(),
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.greenText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(String rating) {
    switch (rating) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Moderate':
        return Colors.orange;
      case 'Poor':
        return Colors.deepOrange;
      case 'Very Poor':
        return Colors.red;
      default:
        return AppColors.greenText;
    }
  }
}

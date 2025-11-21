import 'package:flutter/material.dart';
import '../../../../constants/app_text_styles.dart';

class WeatherRow extends StatelessWidget {
  final num temp;
  final num humidity;
  final num pressure;
  final num windSpeed;

  const WeatherRow({
    super.key,
    required this.temp,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            icon: Icons.thermostat,
            value: '${temp.round()}',
            unit: '°C',
          ),
          _buildVerticalDivider(),
          _buildItem(
            icon: Icons.water_drop,
            value: '${humidity.round()}',
            unit: '%',
          ),
          _buildVerticalDivider(),
          _buildItem(
            icon: Icons.compress,
            value: '${pressure.round()}',
            unit: 'hPa',
          ),
          _buildVerticalDivider(),
          _buildItem(
            icon: Icons.air,
            value: '${windSpeed.round()}',
            unit: 'km/h',
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.black12);
  }

  Widget _buildItem({
    required IconData icon,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.black54,
        ), // Replace with SVG assets later
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium),
        Text(unit, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

// lib/src/features/purifier/presentation/widgets/fan_speed_control.dart
import 'package:flutter/material.dart';

class FanSpeedControl extends StatelessWidget {
  final int currentSpeed;
  final ValueChanged<int> onSpeedChanged;

  const FanSpeedControl({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fan Speed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Slider(
              value: currentSpeed.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: currentSpeed.toString(),
              onChanged: (value) => onSpeedChanged(value.toInt()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final speed = index + 1;
                return Column(
                  children: [
                    Icon(
                      Icons.air,
                      color: speed <= currentSpeed ? Colors.blue : Colors.grey,
                    ),
                    Text('$speed'),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';
import 'package:aqi_app/src/features/purifier/presentation/providers/purifier_provider.dart';
import 'package:aqi_app/src/features/purifier/presentation/widgets/fan_speed_control.dart';
import 'package:aqi_app/src/features/purifier/presentation/widgets/mode_selector.dart';

class PurifierDetailScreen extends ConsumerWidget {
  final String purifierId;

  const PurifierDetailScreen({
    super.key,
    required this.purifierId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purifierAsync = ref.watch(purifierProvider(purifierId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purifier Details'),
      ),
      body: purifierAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (purifier) {
          if (purifier == null) {
            return const Center(child: Text('Purifier not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  purifier.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(context, purifier, ref: ref),
                const SizedBox(height: 16),
                ModeSelector(
                  currentMode: purifier.mode,
                  onModeChanged: (mode) => _onModeChanged(ref, mode),
                ),
                const SizedBox(height: 16),
                FanSpeedControl(
                  currentSpeed: purifier.fanSpeed,
                  onSpeedChanged: (speed) => _onFanSpeedChanged(ref, speed),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PurifierState purifier, {required WidgetRef ref}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status'),
                Switch(
                  value: purifier.status == 'on',
                  onChanged: (value) => _onPowerToggled(ref, value),
                ),
              ],
            ),
            const Divider(),
            Text('Mode: ${purifier.mode}'),
            Text('Fan Speed: ${purifier.fanSpeed}'),
            if (purifier.currentAqi != null)
              Text('Current AQI: ${purifier.currentAqi}'),
            if (purifier.filterLifeRemaining != null)
              Text('Filter Life: ${purifier.filterLifeRemaining!.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  void _onPowerToggled(WidgetRef ref, bool isOn) {
    ref.read(purifierNotifierProvider.notifier).togglePower(purifierId, isOn);
  }

  void _onModeChanged(WidgetRef ref, String mode) {
    ref.read(purifierNotifierProvider.notifier).changeMode(purifierId, mode);
  }

  void _onFanSpeedChanged(WidgetRef ref, int speed) {
    ref.read(purifierNotifierProvider.notifier).setFanSpeed(purifierId, speed);
  }
}

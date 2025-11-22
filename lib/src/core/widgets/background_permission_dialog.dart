import 'package:flutter/material.dart';

/// Dialog to request background notification permissions
class BackgroundPermissionDialog extends StatelessWidget {
  const BackgroundPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.blue),
          SizedBox(width: 12),
          Text('Enable Air Quality Alerts'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stay informed about air quality changes in your area.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            icon: Icons.air,
            title: 'Real-time Monitoring',
            description: 'Get notified when air quality improves or worsens',
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.schedule,
            title: 'Background Updates',
            description: 'Checks AQI every 15 minutes, even when app is closed',
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            icon: Icons.health_and_safety,
            title: 'Health Protection',
            description:
                'Helps you make informed decisions about outdoor activities',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can change this anytime in Settings',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Enable Alerts'),
        ),
      ],
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Show background permission dialog
Future<bool> showBackgroundPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const BackgroundPermissionDialog(),
  );
  return result ?? false;
}

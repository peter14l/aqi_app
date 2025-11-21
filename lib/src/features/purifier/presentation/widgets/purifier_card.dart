// lib/src/features/purifier/presentation/widgets/purifier_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';

class PurifierCard extends StatelessWidget {
  final PurifierState purifier;

  const PurifierCard({
    super.key,
    required this.purifier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint('Tapped purifier: ${purifier.id}');
          final path = '/purifier/${purifier.id}';
          debugPrint('Navigating to: $path');
          context.push(path).then((_) {
            debugPrint('Navigation completed');
          }).catchError((error) {
            debugPrint('Navigation error: $error');
          });
        },
        child: ListTile(
          title: Text(purifier.name),
          subtitle: Text('Status: ${purifier.status} • Mode: ${purifier.mode}'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqi_app/src/core/agents/smart_purifier_agent.dart';
import 'package:aqi_app/src/features/purifier/application/purifier_service.dart';
import 'package:aqi_app/src/features/purifier/domain/repositories/purifier_repository_interface.dart';

export 'package:aqi_app/src/features/purifier/application/purifier_service.dart';
export 'package:aqi_app/src/features/purifier/domain/repositories/purifier_repository_interface.dart' show PurifierRepository;

final purifierRepositoryProvider = Provider<PurifierRepository>((ref) {
  throw UnimplementedError('PurifierRepository not initialized');
});

final purifierAgentProvider = Provider<SmartPurifierAgent>((ref) {
  return SmartPurifierAgent();
});

final purifierServiceProvider = Provider<PurifierService>((ref) {
  final repository = ref.watch(purifierRepositoryProvider);
  final agent = ref.watch(purifierAgentProvider);
  return PurifierService(repository: repository, agent: agent);
});

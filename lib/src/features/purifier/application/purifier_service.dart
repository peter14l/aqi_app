import 'package:aqi_app/src/core/agents/smart_purifier_agent.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';
import 'package:aqi_app/src/features/purifier/domain/repositories/purifier_repository_interface.dart';
import 'package:logger/logger.dart';

class PurifierService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      colors: true,
      printEmojis: true,
    ),
  );

  final PurifierRepository _repository;
  final SmartPurifierAgent _agent;

  PurifierService({
    required PurifierRepository repository,
    required SmartPurifierAgent agent,
  })  : _repository = repository,
        _agent = agent;

  Future<void> init() async {
    // Initialize any required resources
  }

  // Get all purifiers
  Future<List<PurifierState>> getPurifiers() async {
    try {
      return await _repository.getPurifiers();
    } catch (e) {
      _logger.e('Error getting purifiers: $e');
      rethrow;
    }
  }

  // Get a single purifier by ID
  Future<PurifierState?> getPurifier(String id) async {
    try {
      final purifiers = await _repository.getPurifiers();
      try {
        return purifiers.firstWhere((p) => p.id == id);
      } on StateError {
        return null;
      }
    } catch (e) {
      _logger.e('Error getting purifier $id: $e');
      rethrow;
    }
  }

  // Add a new purifier
  Future<void> addPurifier(PurifierState purifier) async {
    try {
      await _repository.addPurifier(purifier);
    } catch (e) {
      print('Error adding purifier: $e');
      rethrow;
    }
  }

  // Update an existing purifier
  Future<void> updatePurifier(PurifierState purifier) async {
    try {
      await _repository.updatePurifier(purifier);
    } catch (e) {
      print('Error updating purifier: $e');
      rethrow;
    }
  }

  // Delete a purifier
  Future<void> deletePurifier(String id) async {
    try {
      await _repository.deletePurifier(id);
    } catch (e) {
      print('Error deleting purifier: $e');
      rethrow;
    }
  }

  Future<PurifierState> controlPurifier({
    required String purifierId,
    required String action,
    Map<String, dynamic>? params,
  }) async {
    try {
      final purifier = await _repository.getPurifier(purifierId);
      if (purifier == null) {
        throw Exception('Purifier not found');
      }

      final input = {
        'action': action,
        'purifierId': purifierId,
        'currentAqi': purifier.currentAqi,
        ...?params,
      };

      final result = await _agent.execute(input);

      final updatedPurifier = purifier.copyWith(
        status: result['status'] ?? purifier.status,
        mode: result['mode'] ?? purifier.mode,
        fanSpeed: result['fanSpeed'] ?? purifier.fanSpeed,
        lastUpdated: DateTime.now(),
        isAutoAdjust: result['autoAdjusted'] ?? false,
        currentAqi: result['aqi'] ?? purifier.currentAqi,
      );

      await _repository.updatePurifier(updatedPurifier);
      return updatedPurifier;
    } catch (e) {
      print('Error controlling purifier: $e');
      rethrow;
    }
  }

  Future<PurifierState> autoAdjustPurifier(String purifierId, int currentAqi) async {
    return controlPurifier(
      purifierId: purifierId,
      action: 'auto_adjust',
      params: {'currentAqi': currentAqi},
    );
  }

  Future<PurifierState> turnOn(String purifierId, {int? aqi}) async {
    return controlPurifier(
      purifierId: purifierId,
      action: 'turn_on',
      params: aqi != null ? {'currentAqi': aqi} : null,
    );
  }

  Future<PurifierState> turnOff(String purifierId) async {
    return controlPurifier(
      purifierId: purifierId,
      action: 'turn_off',
    );
  }

  Future<PurifierState> setMode(String purifierId, String mode) async {
    return controlPurifier(
      purifierId: purifierId,
      action: 'set_mode',
      params: {'mode': mode},
    );
  }

  Future<Map<String, dynamic>> getStatus(String purifierId) async {
    final purifier = await _repository.getPurifier(purifierId);
    if (purifier == null) {
      throw Exception('Purifier not found');
    }

    return {
      'status': purifier.status,
      'mode': purifier.mode,
      'fanSpeed': purifier.fanSpeed,
      'isConnected': purifier.isConnected,
      'currentAqi': purifier.currentAqi,
      'filterLifeRemaining': purifier.filterLifeRemaining,
    };
  }

  Future<PurifierState> updateAqi(String purifierId, int aqi) async {
    final purifier = await _repository.getPurifier(purifierId);
    if (purifier == null) {
      throw Exception('Purifier not found');
    }

    final updatedPurifier = purifier.copyWith(
      currentAqi: aqi,
      lastUpdated: DateTime.now(),
    );

    await _repository.updatePurifier(updatedPurifier);
    return updatedPurifier;
  }

  Future<double> getFilterLife(String purifierId) async {
    return await _repository.getFilterLife(purifierId);
  }

  Future<void> close() async {
    await _repository.close();
  }
}

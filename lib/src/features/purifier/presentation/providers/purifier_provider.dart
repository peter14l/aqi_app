import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';
import 'package:aqi_app/src/features/purifier/application/providers.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    colors: true,
    printEmojis: true,
  ),
);

// Provider for the purifier state
final purifierListProvider = FutureProvider<List<PurifierState>>((ref) async {
  final service = ref.watch(purifierServiceProvider);
  return await service.getPurifiers();
});

// Provider for a single purifier
final purifierProvider = FutureProvider.autoDispose.family<PurifierState, String>((ref, id) async {
  final service = ref.watch(purifierServiceProvider);
  try {
    final purifier = await service.getPurifier(id);
    if (purifier == null) {
      throw Exception('Purifier with id $id not found');
    }
    return purifier;
  } catch (e, stackTrace) {
    _logger.e('Failed to load purifier', error: e, stackTrace: stackTrace);
    throw Exception('Failed to load purifier: $e');
  }
});

// Notifier for managing purifier state
class PurifierNotifier extends StateNotifier<AsyncValue<List<PurifierState>>> {
  final PurifierService _service;
  
  PurifierNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadPurifiers();
  }
  
  Future<void> _loadPurifiers() async {
    state = const AsyncValue.loading();
    try {
      final purifiers = await _service.getPurifiers();
      state = AsyncValue.data(purifiers);
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to load purifiers: ${e.toString()}', stackTrace);
    }
  }
  
  Future<void> addPurifier(PurifierState purifier) async {
    try {
      await _service.addPurifier(purifier);
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to add purifier: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> updatePurifier(PurifierState purifier) async {
    try {
      await _service.updatePurifier(purifier);
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to update purifier: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> deletePurifier(String id) async {
    try {
      await _service.deletePurifier(id);
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to delete purifier: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> togglePower(String id, bool isOn) async {
    try {
      if (isOn) {
        await _service.turnOn(id);
      } else {
        await _service.turnOff(id);
      }
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to toggle power: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> changeMode(String id, String mode) async {
    try {
      await _service.controlPurifier(
        purifierId: id,
        action: 'set_mode',
        params: {'mode': mode},
      );
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to change mode: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> setFanSpeed(String id, int speed) async {
    try {
      // Map fan speed to a mode that the SmartPurifierAgent understands
      // 1: low, 2: medium, 3: high, 4: turbo, 5: max
      final mode = ['low', 'medium', 'high', 'turbo', 'max'][speed - 1];
      
      await _service.controlPurifier(
        purifierId: id,
        action: 'set_mode',
        params: {'mode': mode},
      );
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to set fan speed: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> autoAdjust(String id, int aqi) async {
    try {
      await _service.controlPurifier(
        purifierId: id,
        action: 'auto_adjust',
        params: {'aqi': aqi},
      );
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to auto-adjust purifier: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateAqi(String id, int aqi) async {
    try {
      await _service.controlPurifier(
        purifierId: id,
        action: 'update_aqi',
        params: {'aqi': aqi},
      );
      await _loadPurifiers();
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to update AQI: ${e.toString()}', stackTrace);
      rethrow;
    }
  }
}

// Provider for the notifier
final purifierNotifierProvider = StateNotifierProvider<PurifierNotifier, AsyncValue<List<PurifierState>>>((ref) {
  final service = ref.watch(purifierServiceProvider);
  return PurifierNotifier(service);
});

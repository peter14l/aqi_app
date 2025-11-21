import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';
import 'package:aqi_app/src/features/purifier/domain/repositories/purifier_repository_interface.dart';
import 'package:aqi_app/src/features/purifier/data/datasources/purifier_local_data_source.dart';

class PurifierRepositoryImpl implements PurifierRepository {
  final PurifierLocalDataSource _localDataSource;

  PurifierRepositoryImpl({required PurifierLocalDataSource localDataSource}) 
      : _localDataSource = localDataSource;

  @override
  Future<List<PurifierState>> getPurifiers() async {
    return await _localDataSource.getPurifiers();
  }

  @override
  Future<PurifierState?> getPurifier(String id) async {
    return await _localDataSource.getPurifier(id);
  }

  @override
  Future<void> addPurifier(PurifierState purifier) async {
    await _localDataSource.addPurifier(purifier);
  }

  @override
  Future<void> updatePurifier(PurifierState purifier) async {
    await _localDataSource.updatePurifier(purifier);
  }

  @override
  Future<void> deletePurifier(String id) async {
    await _localDataSource.deletePurifier(id);
  }

  @override
  Future<void> togglePower(String id, bool isOn) async {
    final purifier = await getPurifier(id);
    if (purifier != null) {
      await updatePurifier(
        purifier.copyWith(
          status: isOn ? 'on' : 'off',
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> changeMode(String id, String mode) async {
    final purifier = await getPurifier(id);
    if (purifier != null) {
      await updatePurifier(
        purifier.copyWith(
          mode: mode,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> setFanSpeed(String id, int speed) async {
    final purifier = await getPurifier(id);
    if (purifier != null) {
      await updatePurifier(
        purifier.copyWith(
          fanSpeed: speed,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPurifierHistory(
    String id, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // For now, return empty list. This would be implemented with actual data source
    return [];
  }

  @override
  Future<double> getFilterLife(String id) async {
    final purifier = await getPurifier(id);
    return purifier?.filterLifeRemaining ?? 100.0; // Default to 100% if not set
  }

  @override
  Future<int> getCurrentAqi(String id) async {
    final purifier = await getPurifier(id);
    return purifier?.currentAqi ?? 0; // Default to 0 if not set
  }

  @override
  Future<void> init() async {
    // Initialize any required resources
  }

  @override
  Future<void> close() async {
    await _localDataSource.close();
  }
}

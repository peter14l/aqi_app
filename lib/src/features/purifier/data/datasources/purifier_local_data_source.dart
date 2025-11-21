import 'package:hive/hive.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';

class PurifierLocalDataSource {
  static const String _boxName = 'purifiers';
  
  Future<Box<PurifierState>> get _box async {
    return await Hive.openBox<PurifierState>(_boxName);
  }
  
  Future<List<PurifierState>> getPurifiers() async {
    final box = await _box;
    return box.values.toList();
  }
  
  Future<PurifierState?> getPurifier(String id) async {
    final box = await _box;
    return box.get(id);
  }
  
  Future<void> addPurifier(PurifierState purifier) async {
    final box = await _box;
    await box.put(purifier.id, purifier);
  }
  
  Future<void> updatePurifier(PurifierState purifier) async {
    final box = await _box;
    await box.put(purifier.id, purifier);
  }
  
  Future<void> deletePurifier(String id) async {
    final box = await _box;
    await box.delete(id);
  }
  
  Future<void> close() async {
    final box = await _box;
    await box.close();
  }
}

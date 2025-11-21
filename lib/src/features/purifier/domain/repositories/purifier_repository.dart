import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';

abstract class PurifierRepository {
  // Get all purifiers
  Future<List<PurifierState>> getPurifiers();
  
  // Get a specific purifier by ID
  Future<PurifierState> getPurifier(String id);
  
  // Add a new purifier
  Future<void> addPurifier(PurifierState purifier);
  
  // Update an existing purifier
  Future<void> updatePurifier(PurifierState purifier);
  
  // Delete a purifier
  Future<void> deletePurifier(String id);
  
  // Toggle purifier power
  Future<void> togglePower(String id, bool isOn);
  
  // Change purifier mode
  Future<void> changeMode(String id, String mode);
  
  // Adjust fan speed
  Future<void> setFanSpeed(String id, int speed);
  
  // Get purifier history
  Future<List<Map<String, dynamic>>> getPurifierHistory(String id, {DateTime? startDate, DateTime? endDate});
  
  // Get filter life remaining
  Future<double> getFilterLife(String id);
  
  // Get current AQI from purifier
  Future<int> getCurrentAqi(String id);
}

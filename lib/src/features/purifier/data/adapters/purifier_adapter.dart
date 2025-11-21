import 'package:hive/hive.dart';
import 'package:aqi_app/src/features/purifier/domain/purifier_model.dart';

class PurifierAdapter extends TypeAdapter<PurifierState> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  PurifierState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return PurifierState(
      id: fields[0] as String,
      name: fields[1] as String,
      status: fields[2] as String,
      mode: fields[3] as String,
      fanSpeed: fields[4] as int,
      isConnected: fields[5] as bool,
      lastUpdated: fields[6] as DateTime,
      currentAqi: fields[7] as int?,
      location: fields[8] as String?,
      filterLifeRemaining: fields[9] as double?,
      isAutoAdjust: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, PurifierState obj) {
    writer
      ..writeByte(11) // Number of fields
      ..writeByte(0) // Field ID 0
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.fanSpeed)
      ..writeByte(5)
      ..write(obj.isConnected)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.currentAqi)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.filterLifeRemaining)
      ..writeByte(10)
      ..write(obj.isAutoAdjust);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurifierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// Register the adapter
void registerPurifierAdapter() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(PurifierAdapter());
  }
}

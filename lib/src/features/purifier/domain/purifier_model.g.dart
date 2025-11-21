// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purifier_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurifierStateAdapter extends TypeAdapter<PurifierState> {
  @override
  final int typeId = 0;

  @override
  PurifierState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurifierState(
      id: fields[1] as String,
      name: fields[2] as String,
      status: fields[3] as String,
      mode: fields[4] as String,
      fanSpeed: fields[5] as int,
      isConnected: fields[6] as bool,
      lastUpdated: fields[7] as DateTime,
      currentAqi: fields[8] as int?,
      location: fields[9] as String?,
      filterLifeRemaining: fields[10] as double?,
      isAutoAdjust: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PurifierState obj) {
    writer
      ..writeByte(11)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.mode)
      ..writeByte(5)
      ..write(obj.fanSpeed)
      ..writeByte(6)
      ..write(obj.isConnected)
      ..writeByte(7)
      ..write(obj.lastUpdated)
      ..writeByte(8)
      ..write(obj.currentAqi)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.filterLifeRemaining)
      ..writeByte(11)
      ..write(obj.isAutoAdjust);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurifierStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurifierStatusAdapter extends TypeAdapter<PurifierStatus> {
  @override
  final int typeId = 1;

  @override
  PurifierStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PurifierStatus.on;
      case 1:
        return PurifierStatus.off;
      case 2:
        return PurifierStatus.error;
      default:
        return PurifierStatus.on;
    }
  }

  @override
  void write(BinaryWriter writer, PurifierStatus obj) {
    switch (obj) {
      case PurifierStatus.on:
        writer.writeByte(0);
        break;
      case PurifierStatus.off:
        writer.writeByte(1);
        break;
      case PurifierStatus.error:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurifierStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurifierStateImpl _$$PurifierStateImplFromJson(Map<String, dynamic> json) =>
    _$PurifierStateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      mode: json['mode'] as String,
      fanSpeed: (json['fanSpeed'] as num).toInt(),
      isConnected: json['isConnected'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      currentAqi: (json['currentAqi'] as num?)?.toInt(),
      location: json['location'] as String?,
      filterLifeRemaining: (json['filterLifeRemaining'] as num?)?.toDouble(),
      isAutoAdjust: json['isAutoAdjust'] as bool? ?? false,
    );

Map<String, dynamic> _$$PurifierStateImplToJson(_$PurifierStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'mode': instance.mode,
      'fanSpeed': instance.fanSpeed,
      'isConnected': instance.isConnected,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'currentAqi': instance.currentAqi,
      'location': instance.location,
      'filterLifeRemaining': instance.filterLifeRemaining,
      'isAutoAdjust': instance.isAutoAdjust,
    };

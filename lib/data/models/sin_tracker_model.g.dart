// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sin_tracker_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SinRecordAdapter extends TypeAdapter<SinRecord> {
  @override
  final int typeId = 10;

  @override
  SinRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SinRecord(
      sinTypeId: fields[0] as String,
      hasSinned: fields[1] as bool? ?? false,
      kaffaraDone: fields[2] as bool? ?? false,
      kaffaraType: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SinRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sinTypeId)
      ..writeByte(1)
      ..write(obj.hasSinned)
      ..writeByte(2)
      ..write(obj.kaffaraDone)
      ..writeByte(3)
      ..write(obj.kaffaraType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SinRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SinTypeAdapter extends TypeAdapter<SinType> {
  @override
  final int typeId = 11;

  @override
  SinType read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SinType(
      id: fields[0] as String,
      name: fields[1] as String,
      isDefault: fields[2] as bool? ?? false,
      icon: fields[3] as String? ?? 'warning',
    );
  }

  @override
  void write(BinaryWriter writer, SinType obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isDefault)
      ..writeByte(3)
      ..write(obj.icon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SinTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailySinRecordAdapter extends TypeAdapter<DailySinRecord> {
  @override
  final int typeId = 12;

  @override
  DailySinRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySinRecord(
      date: fields[0] as String,
      records: (fields[1] as List?)?.cast<SinRecord>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, DailySinRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.records);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySinRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

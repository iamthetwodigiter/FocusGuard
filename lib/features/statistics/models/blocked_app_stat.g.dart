// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_app_stat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockedAppStatAdapter extends TypeAdapter<BlockedAppStat> {
  @override
  final int typeId = 2;

  @override
  BlockedAppStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlockedAppStat(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      blockCount: fields[2] as int,
      lastBlockedTime: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BlockedAppStat obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.blockCount)
      ..writeByte(3)
      ..write(obj.lastBlockedTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedAppStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

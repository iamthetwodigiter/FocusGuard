// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WebsiteInfoAdapter extends TypeAdapter<WebsiteInfo> {
  @override
  final int typeId = 3;

  @override
  WebsiteInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebsiteInfo(
      url: fields[0] as String,
      isBlocked: fields[1] as bool,
      addedAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WebsiteInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.isBlocked)
      ..writeByte(2)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebsiteInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

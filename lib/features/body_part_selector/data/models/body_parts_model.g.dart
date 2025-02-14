// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_parts_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyPartsHiveWrapperAdapter extends TypeAdapter<BodyPartsHiveWrapper> {
  @override
  final int typeId = 0;

  @override
  BodyPartsHiveWrapper read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyPartsHiveWrapper(
      (fields[0] as Map).cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, BodyPartsHiveWrapper obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.selectedBodyParts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyPartsHiveWrapperAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

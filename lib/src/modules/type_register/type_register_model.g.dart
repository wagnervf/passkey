// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_register_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TypeRegiterModelAdapter extends TypeAdapter<TypeRegiterModel> {
  @override
  final int typeId = 1;

  @override
  TypeRegiterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TypeRegiterModel(
      id: fields[0] as int,
      name: fields[1] as String,
      icon: fields[2] as String,
      color: fields[3] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, TypeRegiterModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.color);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TypeRegiterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

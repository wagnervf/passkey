// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegisterModelAdapter extends TypeAdapter<RegisterModel> {
  @override
  final int typeId = 0;

  @override
  RegisterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegisterModel(
      id: fields[0] as String,
      name: fields[1] as String?,
      username: fields[2] as String?,
      password: fields[3] as String?,
      url: fields[4] as String?,
      note: fields[5] as String?,
      type: fields[6] as TypeRegiterModel?,
      selectedApp: fields[7] as InstalledAppModel?,
    );
  }

  @override
  void write(BinaryWriter writer, RegisterModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.selectedApp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installed_app_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InstalledAppModelAdapter extends TypeAdapter<InstalledAppModel> {
  @override
  final int typeId = 2;

  @override
  InstalledAppModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InstalledAppModel(
      id: fields[0] as int,
      name: fields[1] as String,
      iconPath: fields[2] as String?,
      iconBytes: fields[3] as Uint8List?,
      packageName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InstalledAppModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconPath)
      ..writeByte(3)
      ..write(obj.iconBytes)
      ..writeByte(4)
      ..write(obj.packageName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InstalledAppModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'installed_app_model.g.dart';

@HiveType(typeId: 2)
class InstalledAppModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? iconPath;

  @HiveField(3)
  final Uint8List? iconBytes;

  @HiveField(4)
  final String? packageName;

  InstalledAppModel({
    required this.id,
    required this.name,
    this.iconPath,
    this.iconBytes,
    this.packageName,
  });

  InstalledAppModel copyWith({
    int? id,
    String? name,
    String? iconPath,
    Uint8List? iconBytes,
    String? packageName,
  }) {
    return InstalledAppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      iconBytes: iconBytes ?? this.iconBytes,
      packageName: packageName ?? this.packageName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'iconBytes': iconBytes?.asMap(),
      'packageName': packageName,
    };
  }

  factory InstalledAppModel.fromMap(Map<String, dynamic> map) {
    return InstalledAppModel(
      id: map['id'] as int,
      name: map['name'] as String,
      iconPath: map['iconPath'] != null ? map['iconPath'] as String : null,
      iconBytes: map['iconBytes'] != null ? Uint8List.fromList(map['iconBytes']) : null,
      packageName: map['packageName'] != null ? map['packageName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InstalledAppModel.fromJson(String source) => InstalledAppModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InstalledAppModel(id: $id, name: $name, iconPath: $iconPath, iconBytes: $iconBytes, packageName: $packageName)';
  }

  @override
  bool operator ==(covariant InstalledAppModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.iconPath == iconPath &&
      other.iconBytes == iconBytes &&
      other.packageName == packageName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      iconPath.hashCode ^
      iconBytes.hashCode ^
      packageName.hashCode;
  }
}

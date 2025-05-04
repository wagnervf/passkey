// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

class InstalledAppModel {
  final int id;
  final String name;
  final String? iconPath;
  final Uint8List? iconBytes;
 // final String? iconBytes;
  
  InstalledAppModel({
    this.id = 0,
    this.name = '',
    this.iconPath,
    this.iconBytes,
  });

 

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'iconBytes': iconBytes?.asMap(),
    };
  }

  factory InstalledAppModel.fromMap(Map<String, dynamic> map) {
    return InstalledAppModel(
      id: map['id'] as int,
      name: map['name'] as String,
      iconPath: map['iconPath'] != null ? map['iconPath'] as String : null,
      iconBytes: map['iconBytes'] != null ? Uint8List.fromList(base64Decode(map['iconBytes'])) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InstalledAppModel.fromJson(String source) => InstalledAppModel.fromMap(json.decode(source) as Map<String, dynamic>);

  InstalledAppModel copyWith({
    int? id,
    String? name,
    String? iconPath,
    Uint8List? iconBytes,
  }) {
    return InstalledAppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      iconBytes: iconBytes ?? this.iconBytes,
    );
  }

  @override
  String toString() {
    return 'InstalledAppModel(id: $id, name: $name, iconPath: $iconPath, iconBytes: $iconBytes)';
  }

  @override
  bool operator ==(covariant InstalledAppModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.iconPath == iconPath &&
      other.iconBytes == iconBytes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      iconPath.hashCode ^
      iconBytes.hashCode;
  }
}

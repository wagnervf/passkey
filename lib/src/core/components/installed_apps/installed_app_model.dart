// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

class InstalledAppModel {
  final String name;
  final String? iconPath;
  final Uint8List? iconBytes;
  
  InstalledAppModel({
    this.name = '',
    this.iconPath,
    this.iconBytes,
  });

 

 



  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'iconPath': iconPath,
      'iconBytes': iconBytes != null ? base64Encode(iconBytes!) : null,
    };
  }

  factory InstalledAppModel.fromMap(Map<String, dynamic> map) {
    return InstalledAppModel(
      name: map['name'] as String,
      iconPath: map['iconPath'] != null ? map['iconPath'] as String : null,
      iconBytes: map['iconBytes'] != null ? base64Decode(map['iconBytes'] as String) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InstalledAppModel.fromJson(String source) => InstalledAppModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

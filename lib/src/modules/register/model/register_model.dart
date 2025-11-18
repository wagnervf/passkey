// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/modules/type_register/type_register_model.dart';
import 'package:uuid/uuid.dart';

part 'register_model.g.dart';

@HiveType(typeId: 0)
class RegisterModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final String? username;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? url;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final TypeRegiterModel? type;

  @HiveField(7)
  final InstalledAppModel? selectedApp;

   @HiveField(8)
  final bool isFavorite;

  RegisterModel(
      {
        required 
      this.id,
      this.name,
      this.username,
      this.password,
      this.url,
      this.note,
      this.type,
      this.selectedApp, 
      this.isFavorite = false,});

  factory RegisterModel.fromCsv(List<dynamic> row) {
    return RegisterModel(
        // name: row[0] ?? '',
        // url: row[1] ?? '',
        // username: row[2] ?? '',
        // password: row[3] ?? '',
        // note: row[4] ?? '',
        // id: Uuid().v4(), 
        // isFavorite: row[5] == 'true' ? true : false

         id: Uuid().v4(),
    name: row[0] ?? '',
    url: row[1] ?? '',
    username: row[2] ?? '',
    password: row[3] ?? '',
    note: row.length > 4 ? row[4] : '',
    isFavorite: false,
        
        );
  }

  RegisterModel copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? url,
    String? note,
    TypeRegiterModel? type,
    InstalledAppModel? selectedApp,
    bool? isFavorite,
  }) {
    return RegisterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      note: note ?? this.note,
      type: type ?? this.type,
      selectedApp: selectedApp ?? this.selectedApp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'url': url,
      'note': note,
      'type': type?.toMap(),
      'selectedApp': selectedApp?.toMap(),
      'isFavorite': isFavorite,
    };
  }


  factory RegisterModel.fromMap(Map<String, dynamic> map) {
  final rawId = (map['id'] ?? '').toString().trim();

  return RegisterModel(
    id: rawId.isNotEmpty ? rawId : const Uuid().v4(),
    name: map['name']?.toString(),
    username: map['username']?.toString(),
    password: map['password']?.toString(),
    url: map['url']?.toString(),
    note: map['note']?.toString(),
    type: map['type'] != null
        ? TypeRegiterModel.fromMap(map['type'] as Map<String, dynamic>)
        : null,
    selectedApp: map['selectedApp'] != null
        ? InstalledAppModel.fromMap(
            map['selectedApp'] as Map<String, dynamic>,
          )
        : null,
        isFavorite: map['isFavorite'] ?? false,
        
  );
}

factory RegisterModel.fromJson(Map<String, dynamic> map) {
  return RegisterModel.fromMap(map);
}



  @override
  String toString() {
    return 'RegisterModel(id: $id, name: $name, username: $username, password: $password, url: $url, note: $note, type: $type, selectedApp: $selectedApp, isFavorite: $isFavorite )';
  }

  @override
  bool operator ==(covariant RegisterModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.username == username &&
        other.password == password &&
        other.url == url &&
        other.note == note &&
        other.type == type &&
        other.selectedApp == selectedApp &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        username.hashCode ^
        password.hashCode ^
        url.hashCode ^
        note.hashCode ^
        type.hashCode ^
        selectedApp.hashCode ^
        isFavorite.hashCode;
        
  }

  @override
  List<Object?> get props =>
      [id, name, username, password, url, note, type, selectedApp, isFavorite];

  //String toJson() => json.encode(toMap());

  String toJson() {
  return json.encode({
    'id': id,
    'name': name,
    'username': username,
    'password': password,
    'url': url,
    'note': note,
    'isFavorite': isFavorite,
  });
}
}

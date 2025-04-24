// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:passkey/src/core/components/installed_apps/installed_app_model.dart';
import 'package:passkey/src/modules/register/model/tipo_registro_model.dart';

class RegisterModel {
  final String id;
  final String? name;
  final String? username;
  final String? password;
  final String? url;
  final String? note;
  final TipoRegisterModel? type;
  final InstalledAppModel? selectedApp;

  RegisterModel({
    this.id = '',
    this.name,
    this.username,
    this.password,
    this.url,
    this.note,
    this.type,
    this.selectedApp,
  });

  // // Gerar um novo registro com ID único
  // factory RegisterModel.newRegister({
  //   required String title,
  //   String? login,
  //   String? password,
  //   String? description,
  //   String? site,
  //   required TipoRegisterModel type,
  // }) {
  //   return RegisterModel(
  //     id: const Uuid().v4(), // Gera um UUID
  //     title: title,
  //     password: password,
  //     site: site,
  //     type: type,
  //   );
  // }

  RegisterModel copyWith({
    String? id,
    String? name,
    String? username,
    String? password,
    String? url,
    String? note,
    TipoRegisterModel? type,
    InstalledAppModel? selectedApp,
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
    };
  }

  factory RegisterModel.fromMap(Map<String, dynamic> map) {
    return RegisterModel(
      id: map['id'] as String,
      name: map['name'] != null ? map['name'] as String : null,
      username: map['username'] != null ? map['username'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      url: map['url'] != null ? map['url'] as String : null,
      note: map['note'] != null ? map['note'] as String : null,
      type: map['type'] != null ? TipoRegisterModel.fromMap(map['type'] as Map<String,dynamic>) : null,
      selectedApp: map['selectedApp'] != null ? InstalledAppModel.fromMap(map['selectedApp'] as Map<String,dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterModel.fromJson(String source) =>
      RegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RegisterModel(id: $id, name: $name, username: $username, password: $password, url: $url, note: $note, type: $type, selectedApp: $selectedApp)';
  }

  factory RegisterModel.fromCsv(List<dynamic> row) {
    return RegisterModel(
      name: row[0] ?? '',
      url: row[1] ?? '',
      username: row[2] ?? '',
      password: row[3] ?? '',
      note: row[4] ?? '',
    );
  }

  // @override
  // bool operator ==(covariant RegisterModel other) {
  //   if (identical(this, other)) return true;

  //   return
  //     other.id == id &&
  //     other.title == title &&
  //     other.login == login &&
  //     other.password == password &&
  //     other.description == description &&
  //     other.site == site &&
  //     other.type == type;
  // }

  // @override
  // int get hashCode {
  //   return id.hashCode ^
  //     title.hashCode ^
  //     login.hashCode ^
  //     password.hashCode ^
  //     description.hashCode ^
  //     site.hashCode ^
  //     type.hashCode;
  // }

  @override
  bool operator ==(covariant RegisterModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.username == username &&
      other.password == password &&
      other.url == url &&
      other.note == note &&
      other.type == type &&
      other.selectedApp == selectedApp;
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
      selectedApp.hashCode;
  }
}

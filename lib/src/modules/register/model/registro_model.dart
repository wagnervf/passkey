// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:passkey/src/modules/register/model/tipo_registro_model.dart';

class RegisterModel {
  final String id;
  final String title;
  final String? login;
  final String? password;
  final String? description;
  final String? site;
  final TipoRegisterModel? type;
  RegisterModel({
    this.id = '',
    this.title = '',
    this.login,
    this.password,
    this.description,
    this.site,
    this.type,
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
  //     login: login,
  //     password: password,
  //     description: description,
  //     site: site,
  //     type: type,
  //   );
  // }

  RegisterModel copyWith({
    String? id,
    String? title,
    String? login,
    String? password,
    String? description,
    String? site,
    TipoRegisterModel? type,
  }) {
    return RegisterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      login: login ?? this.login,
      password: password ?? this.password,
      description: description ?? this.description,
      site: site ?? this.site,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'login': login,
      'password': password,
      'description': description,
      'site': site,
      'type': type?.toMap(),
    };
  }

  factory RegisterModel.fromMap(Map<String, dynamic> map) {
    return RegisterModel(
      id: map['id'] as String,
      title: map['title'] as String,
      login: map['login'] != null ? map['login'] as String : null,
      password: map['password'] != null ? map['password'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      site: map['site'] != null ? map['site'] as String : null,
      type: map['type'] != null
          ? TipoRegisterModel.fromMap(map['type'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterModel.fromJson(String source) =>
      RegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RegisterModel(id: $id, title: $title, login: $login, password: $password, description: $description, site: $site, type: $type)';
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

    return other.id == id &&
        other.title == title &&
        other.login == login &&
        other.password == password &&
        other.description == description &&
        other.site == site &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        login.hashCode ^
        password.hashCode ^
        description.hashCode ^
        site.hashCode ^
        type.hashCode;
  }
}

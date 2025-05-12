// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/modules/type_register/type_register_model.dart';

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

      RegisterModel({
    required this.id,
    this.name,
    this.username,
    this.password,
    this.url,
    this.note,
    this.type,
    this.selectedApp
  });





  factory RegisterModel.fromCsv(List<dynamic> row) {
    
    return RegisterModel(
      name: row[0] ?? '',
      url: row[1] ?? '',
      username: row[2] ?? '',
      password: row[3] ?? '',
      note: row[4] ?? '',
       id: Uuid().v4()
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
      type: map['type'] != null ? TypeRegiterModel.fromMap(map['type'] as Map<String,dynamic>) : null,
      selectedApp: map['selectedApp'] != null ? InstalledAppModel.fromMap(map['selectedApp'] as Map<String,dynamic>) : null,
    );
  }


  factory RegisterModel.fromJson(String source) => RegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RegisterModel(id: $id, name: $name, username: $username, password: $password, url: $url, note: $note, type: $type, selectedApp: $selectedApp)';
  }


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

@override
List<Object?> get props => [id, name, username, password, url, note, type, selectedApp];

  String toJson() => json.encode(toMap());
}

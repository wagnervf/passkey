// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';


class AuthUserModel {
    final String name;
  final String email;
  final String password;
  AuthUserModel({
    this.name = '',
    this.email = '',
    this.password = '',
  });

  AuthUserModel copyWith({
    String? name,
    String? email,
    String? password,
  }) {
    return AuthUserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthUserModel.fromJson(String source) => AuthUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AuthUserModel(name: $name, email: $email, password: $password)';

  @override
  bool operator ==(covariant AuthUserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.email == email &&
      other.password == password;
  }

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ password.hashCode;
}

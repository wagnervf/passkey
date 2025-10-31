// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class GoogleAuthUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;

  GoogleAuthUserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.photoURL = '',
  });

  factory GoogleAuthUserModel.fromFirebaseUser(user) {
    return GoogleAuthUserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName ?? '',
      photoURL: user.photoURL ?? '',
    );
  }

  @override
  String toString() {
    return 'GoogleAuthUserModel(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL)';
  }

  GoogleAuthUserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return GoogleAuthUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }

  factory GoogleAuthUserModel.fromMap(Map<String, dynamic> map) {
    return GoogleAuthUserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoURL: map['photoURL'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleAuthUserModel.fromJson(String source) => GoogleAuthUserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant GoogleAuthUserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoURL == photoURL;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoURL.hashCode;
  }
}

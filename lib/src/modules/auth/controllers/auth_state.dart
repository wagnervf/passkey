//import 'package:firebase_auth/firebase_auth.dart';


import 'package:keezy/src/modules/auth/model/auth_user_model.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final AuthUserModel? user;

  AuthSuccessState(this.user);
}
class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  AuthErrorState(this.message);
}



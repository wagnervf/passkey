import 'package:flutter/material.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';

class AuthUserProvider extends ChangeNotifier {
  AuthUserModel? _user;

  AuthUserModel? get user => _user;

  static final AuthUserProvider instance = AuthUserProvider._internal();

  AuthUserProvider._internal();

  void setUser(AuthUserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}

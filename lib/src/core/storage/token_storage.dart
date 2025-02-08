import 'dart:convert';

import 'package:passkey/src/core/storage/i_token_storage.dart';
import 'package:passkey/src/modules/auth/model/google_auth_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage implements TokenStorageInterface {
  // ignore: constant_identifier_names
  static const String TOKEN_KEY = 'googleAuthUser';

  // @override
  // Future<String?> getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(TOKEN_KEY);
  // }

  // @override
  // Future<bool> saveToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //    String userJson = jsonEncode(user.toJson());
  // await prefs.setString('googleAuthUser', userJson);
  //   return await prefs.setString(TOKEN_KEY, token);
  // }

  // @override
  // Future<GoogleAuthUserModel?> getUser() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? userJson = prefs.getString(TOKEN_KEY);
  //   if (userJson != null) {
  //     return GoogleAuthUserModel.fromJson(jsonDecode(userJson));
  //   }
  //   return null;
  // }

  @override
  Future<void> saveUser(GoogleAuthUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString(TOKEN_KEY, userJson);
  }

  @override
  Future<GoogleAuthUserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(TOKEN_KEY);
    if (userJson != null) {
     final  userMap = jsonDecode(userJson);
      return GoogleAuthUserModel.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
  }

  @override
  Future<bool> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('theme', theme);
  }

  @override
  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme');
  }
}

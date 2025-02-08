import 'package:passkey/src/modules/auth/model/google_auth_user_model.dart';

abstract class TokenStorageInterface {
  //Future<bool> saveToken(String token);
  //Future<String?> getToken();
  Future<void> deleteToken();

  Future<bool> saveTheme(String theme);
  Future<String?> getTheme();

  Future<void> saveUser(GoogleAuthUserModel user);
  Future<GoogleAuthUserModel?> getUser();
}
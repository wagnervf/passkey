import 'dart:convert';
import 'dart:developer';
import 'package:passkey/src/core/components/encrypt/encrypt_decrypt_services.dart';
import 'package:passkey/src/core/data/services/secure_storage_service.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';

class AuthRepository {
  static const _userKey = 'auth_user';

  final secureStorageService = SecureStorageService();
  final encrypt = EncryptDecryptServices();

  Future<bool> saveUser(AuthUserModel user) async {
    try {
      final encryptedPassword = encrypt.encryptPassword(user.password);
      final userToSave = {
        'name': user.name,
        'email': user.email,
        'password': encryptedPassword,
      };
      secureStorageService.setDataKey(_userKey, json.encode(userToSave));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> logoutAndRemoveUser() async {
    // Remove o usuário
    if (await secureStorageService.hasApiKey(_userKey)) {
      await secureStorageService.deleteApiKey(_userKey);
      await secureStorageService.deleteAll();

      return true;
    } else {
      return false;
    }
  }

  Future<AuthUserModel?> getUser() async {
    final userData = await secureStorageService.getDataKey(_userKey);
    if (userData == '') return null;

    try {
      final jsonUser = json.decode(userData);

      final encryptedPassword = jsonUser['password']?.toString();
      if (encryptedPassword == null) {
        throw Exception('Senha ausente ou inválido no JSON');
      }

      // Descriptografar a senha
      final decryptedPassword = encrypt.decryptPassword(encryptedPassword);

      return AuthUserModel(
        name: jsonUser['name']?.toString() ?? '',
        email: jsonUser['email']?.toString() ?? '',
        password: decryptedPassword,
      );
    } catch (e) {
      log('Erro ao recuperar o usuário: $e');
      return null;
    }
  }

  Future<bool> validatePassword(String inputPassword) async {
    final user = await getUser();
    return user?.password == inputPassword;
  }
}

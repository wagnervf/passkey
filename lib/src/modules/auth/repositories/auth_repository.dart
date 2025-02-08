import 'dart:convert';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AuthRepository {
  static const _userKey = 'user_data';
  static const _encryptionKey = 'my32lengthsupersecretnooneknows1';

  Future<void> saveUser(AuthUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedPassword = _encryptPassword(user.password);
    final userToSave = {
      'name': user.name,
      'email': user.email,
      'password': encryptedPassword,
    };
    prefs.setString(_userKey, json.encode(userToSave));
  }

  Future<bool> logoutAndRemoveUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove o usuário
    if (prefs.containsKey(_userKey)) {
      await prefs.remove(_userKey);
       await prefs.clear();
      return true;
    } else {
      return false;
    }

    // Opcional: Limpar outros dados (se necessário)
    
    
   
  }

  Future<AuthUserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData == null) return null;

    try {
      // Decodificar o JSON armazenado em um mapa
      final jsonUser = json.decode(userData);
      print(jsonUser['password']?.toString());

      // Garantir que o campo "password" seja tratado como String
      final encryptedPassword = jsonUser['password']?.toString();
      if (encryptedPassword == null) {
        throw Exception('Password ausente ou inválido no JSON');
      }

      // Descriptografar a senha
      final decryptedPassword = _decryptPassword(encryptedPassword);

      // Construir o modelo de usuário
      return AuthUserModel(
        name: jsonUser['name']?.toString() ?? '',
        email: jsonUser['email']?.toString() ?? '',
        password: decryptedPassword,
      );
    } catch (e) {
      print('Erro ao recuperar o usuário: $e');
      return null;
    }
  }

  Future<bool> validatePassword(String inputPassword) async {
    final user = await getUser();
    return user?.password == inputPassword;
  }

  String _encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);

    // Concatenar o IV com o texto criptografado
    return '${iv.base64}:${encrypted.base64}';
  }

  String _decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

    // Separar o IV do texto criptografado
    final parts = encryptedPassword.split(':');
    if (parts.length != 2) {
      throw Exception('Dados criptografados inválidos');
    }

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedText = parts[1];

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt64(encryptedText, iv: iv);
  }
}

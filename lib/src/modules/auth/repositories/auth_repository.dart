import 'dart:convert';
import 'dart:developer';

import 'package:keezy/src/core/components/encrypt/encrypt_decrypt_services.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/security/master_password_verifier.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';

class AuthRepository {
  static const _userKey = 'auth_user';

  final SecureStorageService secureStorageService;
  final MasterPasswordVerifier verifier;
  final EncryptDecryptServices _legacyCipher = EncryptDecryptServices();

  AuthRepository({
    SecureStorageService? secureStorageService,
    MasterPasswordVerifier? verifier,
  }) : secureStorageService = secureStorageService ?? SecureStorageService(),
       verifier = verifier ?? MasterPasswordVerifier();

  Future<bool> saveUser(AuthUserModel user) async {
    try {
      if (MasterPasswordPolicy.validate(user.password) != null ||
          await secureStorageService.hasApiKey(_userKey)) {
        return false;
      }

      final userToSave = {
        'name': user.name,
        'email': user.email,
        'passwordVerifier': await verifier.create(user.password),
      };
      final encoded = jsonEncode(userToSave);
      await secureStorageService.setDataKey(_userKey, encoded);

      // Secure storage writes can fail silently on some platform backends.
      // Confirm the complete credential is readable before reporting success.
      if (await secureStorageService.getDataKey(_userKey) != encoded) {
        await secureStorageService.deleteApiKey(_userKey);
        return false;
      }
      return true;
    } catch (_) {
      log('Erro ao cadastrar usuário.');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      final stored = await _readUser();
      if (stored == null) return false;
      stored['name'] = name;
      stored['email'] = email;
      await secureStorageService.setDataKey(_userKey, jsonEncode(stored));
      return true;
    } catch (_) {
      log('Erro ao atualizar perfil.');
      return false;
    }
  }

  Future<bool> hasUser() => secureStorageService.hasApiKey(_userKey);

  Future<bool> logoutAndRemoveUser() async {
    // Remove o usuário
    if (await secureStorageService.hasApiKey(_userKey)) {
      await secureStorageService.deleteApiKey(_userKey);
      return true;
    } else {
      return false;
    }
  }

  Future<AuthUserModel?> getUser() async {
    try {
      final stored = await _readUser();
      if (stored == null) return null;

      if (stored['passwordVerifier'] == null) {
        final legacyPassword = _decryptLegacy(stored);
        if (legacyPassword == null) return null;
        await _migrateLegacy(stored, legacyPassword);
      }

      return AuthUserModel(
        name: stored['name']?.toString() ?? '',
        email: stored['email']?.toString() ?? '',
      );
    } catch (error, stackTrace) {
      log(
        'Erro ao recuperar o usuário para o backup.',
        name: 'keezy.backup',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<bool> validatePassword(String inputPassword) async {
    if (inputPassword.isEmpty) return false;
    try {
      final stored = await _readUser();
      if (stored == null) return false;

      final passwordVerifier = stored['passwordVerifier'];
      if (passwordVerifier != null) {
        return await verifier.verify(inputPassword, passwordVerifier);
      }

      final legacyPassword = _decryptLegacy(stored);
      if (legacyPassword == null ||
          !_equalLegacyPasswords(inputPassword, legacyPassword)) {
        return false;
      }
      await _migrateLegacy(stored, inputPassword);
      return true;
    } catch (_) {
      log('Erro ao validar senha mestra.');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _readUser() async {
    final data = await secureStorageService.getDataKey(_userKey);
    if (data.isEmpty) return null;
    final decoded = jsonDecode(data);
    if (decoded is! Map<String, dynamic>) return null;
    return decoded;
  }

  String? _decryptLegacy(Map<String, dynamic> stored) {
    final encrypted = stored['password'];
    if (encrypted is! String) return null;
    try {
      return _legacyCipher.decryptPassword(encrypted);
    } catch (_) {
      return null;
    }
  }

  Future<void> _migrateLegacy(
    Map<String, dynamic> stored,
    String password,
  ) async {
    final updated = Map<String, dynamic>.from(stored);
    updated.remove('password');
    updated['passwordVerifier'] = await verifier.create(password);
    await secureStorageService.setDataKey(_userKey, jsonEncode(updated));
  }

  bool _equalLegacyPasswords(String input, String stored) {
    final a = utf8.encode(input);
    final b = utf8.encode(stored);
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }
}

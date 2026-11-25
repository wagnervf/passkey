import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';

class MemorySecureStorage extends SecureStorageService {
  final Map<String, String> values = {};
  bool failWrites = false;
  bool discardWrites = false;

  @override
  Future<String> getDataKey(String key) async => values[key] ?? '';

  @override
  Future<bool> hasApiKey(String key) async => values.containsKey(key);

  @override
  Future<void> setDataKey(String key, String value) async {
    if (failWrites) throw StateError('write failed');
    if (discardWrites) return;
    values[key] = value;
  }

  @override
  Future<void> deleteApiKey(String key) async {
    values.remove(key);
  }
}

void main() {
  test(
    'new account stores a salted verifier, never the master password',
    () async {
      final storage = MemorySecureStorage();
      final repository = AuthRepository(secureStorageService: storage);
      const password = 'senha mestra de teste';

      expect(
        await repository.saveUser(
          AuthUserModel(
            name: 'Ana',
            email: 'ana@example.test',
            password: password,
          ),
        ),
        isTrue,
      );

      final saved =
          jsonDecode(storage.values['auth_user']!) as Map<String, dynamic>;
      expect(saved.containsKey('password'), isFalse);
      expect(saved['passwordVerifier']['algorithm'], 'argon2id');
      expect(storage.values['auth_user'], isNot(contains(password)));
      expect(await repository.validatePassword(password), isTrue);
      expect(await repository.validatePassword('senha incorreta'), isFalse);
      expect((await repository.getUser())!.password, isEmpty);
      expect(
        AuthUserModel(name: 'Ana', password: password).toJson(),
        isNot(contains(password)),
      );

      final originalVerifier = saved['passwordVerifier'];
      expect(
        await repository.updateProfile(name: 'Ana Maria', email: ''),
        isTrue,
      );
      final updated =
          jsonDecode(storage.values['auth_user']!) as Map<String, dynamic>;
      expect(updated['name'], 'Ana Maria');
      expect(updated['passwordVerifier'], originalVerifier);
      expect(
        await repository.saveUser(AuthUserModel(password: 'outra senha')),
        isFalse,
      );
    },
  );

  test('account creation confirms the credential was persisted', () async {
    final storage = MemorySecureStorage()..discardWrites = true;
    final repository = AuthRepository(secureStorageService: storage);

    expect(
      await repository.saveUser(
        AuthUserModel(name: 'Eva', password: 'senha longa e unica'),
      ),
      isFalse,
    );
    expect(storage.values, isEmpty);
  });

  test(
    'old encrypted password migrates without changing the password',
    () async {
      final storage = MemorySecureStorage();
      final repository = AuthRepository(secureStorageService: storage);
      const password = 'senha antiga';
      final oldCipher = encrypt.Encrypter(
        encrypt.AES(encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1')),
      );
      final iv = encrypt.IV.fromLength(16);
      storage.values['auth_user'] = jsonEncode({
        'name': 'Bia',
        'email': '',
        'password':
            '${iv.base64}:${oldCipher.encrypt(password, iv: iv).base64}',
      });

      expect(await repository.validatePassword('incorreta'), isFalse);
      expect(await repository.validatePassword(password), isTrue);
      final migrated =
          jsonDecode(storage.values['auth_user']!) as Map<String, dynamic>;
      expect(migrated.containsKey('password'), isFalse);
      expect(migrated['passwordVerifier']['version'], 2);
      expect(await repository.validatePassword(password), isTrue);
      expect((await repository.getUser())!.password, isEmpty);
    },
  );

  test('biometric user lookup also migrates an old credential', () async {
    final storage = MemorySecureStorage();
    final repository = AuthRepository(secureStorageService: storage);
    const password = 'senha biometria';
    final oldCipher = encrypt.Encrypter(
      encrypt.AES(encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1')),
    );
    final iv = encrypt.IV.fromLength(16);
    storage.values['auth_user'] = jsonEncode({
      'name': 'Caio',
      'email': '',
      'password': '${iv.base64}:${oldCipher.encrypt(password, iv: iv).base64}',
    });

    expect((await repository.getUser())!.name, 'Caio');
    expect(storage.values['auth_user'], isNot(contains('"password"')));
    expect(await repository.validatePassword(password), isTrue);
  });

  test(
    'failed secure storage write does not report a created account',
    () async {
      final storage = MemorySecureStorage()..failWrites = true;
      final repository = AuthRepository(secureStorageService: storage);

      expect(
        await repository.saveUser(
          AuthUserModel(name: 'Dani', password: 'senha longa e unica'),
        ),
        isFalse,
      );
      expect(storage.values, isEmpty);
    },
  );

  test(
    'new accounts reject short passwords without writing credentials',
    () async {
      final storage = MemorySecureStorage();
      final repository = AuthRepository(secureStorageService: storage);

      expect(MasterPasswordPolicy.validate('curta'), isNotNull);
      expect(
        await repository.saveUser(AuthUserModel(password: 'curta')),
        isFalse,
      );
      expect(storage.values, isEmpty);
    },
  );
}

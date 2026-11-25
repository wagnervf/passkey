import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/hive/vault_key_manager.dart';
import 'package:keezy/src/core/session/session_manager.dart';
import 'package:keezy/src/core/storage/i_token_storage.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:keezy/src/modules/auth/security/master_password_attempts.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Storage extends SecureStorageService {
  final values = <String, String>{};
  @override
  Future<String> getDataKey(String key) async => values[key] ?? '';
  @override
  Future<bool> hasApiKey(String key) async => values.containsKey(key);
  @override
  Future<void> setDataKey(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> deleteApiKey(String key) async {
    values.remove(key);
  }
}

class _Keys implements VaultKeyStore {
  String? envelope;
  @override
  Future<String?> readPasswordEnvelope() async => envelope;
  @override
  Future<void> writePasswordEnvelope(String value) async {
    envelope = value;
  }

  @override
  Future<void> deletePasswordEnvelope() async {
    envelope = null;
  }

  @override
  Future<String?> readLegacyKey() async => null;
  @override
  Future<void> deleteLegacyKey() async {}
  @override
  Future<String?> readBiometricKey() async => null;
  @override
  Future<void> writeBiometricKey(String value) async {}
  @override
  Future<void> deleteBiometricKey() async {}
  @override
  Future<String?> readDeletionMarker() async => null;
  @override
  Future<void> writeDeletionMarker() async {}
  @override
  Future<void> deleteDeletionMarker() async {}
}

class _Tokens implements TokenStorageInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'wrong guesses delay login across restart, then correct password unlocks',
    () async {
      SharedPreferences.setMockInitialValues({});
      final directory = await Directory.systemTemp.createTemp(
        'keezy-attempts-',
      );
      Hive.init(directory.path);
      RegisterHive.init(manager: VaultKeyManager(store: _Keys()));
      SessionManager.setForeground(true);
      const password = 'uma senha mestra longa';
      final storage = _Storage();
      final repository = AuthRepository(secureStorageService: storage);
      var time = DateTime(2026, 11, 25);
      AuthController newController() => AuthController(
        tokenStorage: _Tokens(),
        authRepository: repository,
        passwordAttempts: MasterPasswordAttempts(
          storage: storage,
          now: () => time,
        ),
      );

      try {
        expect(
          await repository.saveUser(
            AuthUserModel(name: 'Ana', password: password),
          ),
          isTrue,
        );
        await RegisterHive.unlockWithPassword(password, createIfMissing: true);
        await RegisterHive.lock();

        final controller = newController();
        for (var i = 0; i < 5; i++) {
          expect(await controller.login('errada'), isFalse);
        }
        expect(
          (controller.state as AuthErrorState).message,
          contains('30 segundos'),
        );
        await controller.close();

        final restarted = newController();
        expect(await restarted.login(password), isFalse);
        expect(
          (restarted.state as AuthErrorState).message,
          contains('30 segundos'),
        );
        expect(RegisterHive.isUnlocked, isFalse);
        time = time.add(const Duration(seconds: 30));
        expect(await restarted.login(password), isTrue);
        expect(RegisterHive.isUnlocked, isTrue);
        await restarted.lockVault();
        expect(await restarted.passwordAttempts.remaining(), Duration.zero);
        await restarted.close();
      } finally {
        await RegisterHive.lock();
        await Hive.close();
        SessionManager.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
}

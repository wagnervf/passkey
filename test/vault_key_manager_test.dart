import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:keezy/src/core/hive/vault_key_manager.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class MemoryVaultKeyStore implements VaultKeyStore {
  String? passwordEnvelope;
  String? legacy;
  String? biometric;
  bool failPasswordWrite = false;
  String? deletionMarker;

  @override
  Future<String?> readPasswordEnvelope() async => passwordEnvelope;
  @override
  Future<void> writePasswordEnvelope(String value) async {
    if (failPasswordWrite) throw StateError('write failed');
    passwordEnvelope = value;
  }

  @override
  Future<void> deletePasswordEnvelope() async {
    passwordEnvelope = null;
  }

  @override
  Future<String?> readLegacyKey() async => legacy;
  @override
  Future<void> deleteLegacyKey() async {
    legacy = null;
  }

  @override
  Future<String?> readBiometricKey() async => biometric;
  @override
  Future<void> writeBiometricKey(String value) async {
    biometric = value;
  }

  @override
  Future<void> deleteBiometricKey() async {
    biometric = null;
  }

  @override
  Future<String?> readDeletionMarker() async => deletionMarker;
  @override
  Future<void> writeDeletionMarker() async {
    deletionMarker = 'empty';
  }

  @override
  Future<void> deleteDeletionMarker() async {
    deletionMarker = null;
  }
}

void main() {
  late Directory directory;
  late MemoryVaultKeyStore store;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('keezy-vault-test-');
    Hive.init(directory.path);
    store = MemoryVaultKeyStore();
    RegisterHive.init(manager: VaultKeyManager(store: store));
  });

  tearDown(() async {
    await RegisterHive.lock();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'new vault remains closed until password unlock and survives reopening',
    () async {
      final vault = RegisterHive();
      expect(RegisterHive.isUnlocked, isFalse);
      expect(() => vault.getAllRegisters(), throwsStateError);

      await RegisterHive.unlockWithPassword(
        'senha longa',
        createIfMissing: true,
      );
      await vault.addRegister(RegisterModel(id: 'one', password: 'segredo'));
      expect(store.passwordEnvelope, isNotNull);
      expect(store.legacy, isNull);
      expect(store.passwordEnvelope, isNot(contains('senha longa')));
      await RegisterHive.lock();

      await expectLater(
        RegisterHive.unlockWithPassword('senha errada'),
        throwsA(isA<Exception>()),
      );
      expect(RegisterHive.isUnlocked, isFalse);
      await RegisterHive.unlockWithPassword('senha longa');
      expect(vault.getRegister('one')?.password, 'segredo');
    },
  );

  test('legacy box is retained when password credential write fails', () async {
    final oldKey = List<int>.generate(32, (index) => index);
    store.legacy = base64Encode(oldKey);
    final oldBox = await Hive.openBox<RegisterModel>(
      RegisterHive.boxName,
      encryptionCipher: HiveAesCipher(oldKey),
    );
    await oldBox.put('one', RegisterModel(id: 'one', password: 'antiga'));
    await oldBox.close();

    store.failPasswordWrite = true;
    await expectLater(
      RegisterHive.unlockWithPassword('senha mestra'),
      throwsStateError,
    );
    expect(store.legacy, base64Encode(oldKey));
    expect(store.passwordEnvelope, isNull);
    expect(RegisterHive.isUnlocked, isFalse);

    store.failPasswordWrite = false;
    await RegisterHive.unlockWithPassword('senha mestra');
    expect(store.legacy, isNull);
    expect(RegisterHive().getRegister('one')?.password, 'antiga');
    await RegisterHive.lock();
    await RegisterHive.unlockWithPassword('senha mestra');
    expect(RegisterHive().count(), 1);
  });

  test(
    'biometric credential uses the same data key and can be removed',
    () async {
      await RegisterHive.unlockWithPassword('senha', createIfMissing: true);
      await RegisterHive().addRegister(
        RegisterModel(id: 'one', password: 'dado'),
      );
      await RegisterHive.enableBiometrics();
      expect(store.biometric, isNotNull);
      await RegisterHive.lock();
      await RegisterHive.unlockWithBiometrics();
      expect(RegisterHive().getRegister('one')?.password, 'dado');
      await RegisterHive.lock();
      await RegisterHive.disableBiometrics();
      await expectLater(RegisterHive.unlockWithBiometrics(), throwsStateError);
    },
  );

  test('old unencrypted box migrates only after unlock', () async {
    final oldBox = await Hive.openBox<RegisterModel>(RegisterHive.oldBoxName);
    await oldBox.put('one', RegisterModel(id: 'one', password: 'antiga'));
    await oldBox.close();
    expect(await Hive.boxExists(RegisterHive.oldBoxName), isTrue);
    await RegisterHive.unlockWithPassword('senha', createIfMissing: true);
    expect(RegisterHive().getRegister('one')?.password, 'antiga');
    expect(await Hive.boxExists(RegisterHive.oldBoxName), isFalse);
  });

  test('empty vault deletion resumes after app restart', () async {
    await RegisterHive.unlockWithPassword('senha', createIfMissing: true);
    await RegisterHive.markEmptyVaultForDeletion();
    await RegisterHive.lock();

    await RegisterHive.completePendingDeletion();
    expect(await Hive.boxExists(RegisterHive.boxName), isFalse);
    expect(store.passwordEnvelope, isNull);
    expect(store.deletionMarker, isNull);

    await RegisterHive.unlockWithPassword('nova senha', createIfMissing: true);
    expect(RegisterHive.isUnlocked, isTrue);
  });
}

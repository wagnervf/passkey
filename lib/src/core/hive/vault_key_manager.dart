import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the independent ways of unlocking one Hive data key.
abstract class VaultKeyStore {
  Future<String?> readPasswordEnvelope();
  Future<void> writePasswordEnvelope(String value);
  Future<void> deletePasswordEnvelope();
  Future<String?> readLegacyKey();
  Future<void> deleteLegacyKey();
  Future<String?> readBiometricKey();
  Future<void> writeBiometricKey(String value);
  Future<void> deleteBiometricKey();
  Future<String?> readDeletionMarker();
  Future<void> writeDeletionMarker();
  Future<void> deleteDeletionMarker();
}

class DeviceVaultKeyStore implements VaultKeyStore {
  static const _passwordKey = 'keezy_vault_password_v1';
  static const _legacyKey = 'keezy_aes_key_v1';
  static const _biometricKey = 'keezy_vault_biometric_v1';
  static const _deletionMarker = 'keezy_vault_delete_pending_v1';

  // Keep the legacy storage options: changing them can make existing keys
  // inaccessible on upgraded installations.
  final FlutterSecureStorage _ordinary = const FlutterSecureStorage();
  final FlutterSecureStorage _biometric = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      storageNamespace: 'keezy_vault_biometric_v1',
      keyCipherAlgorithm: KeyCipherAlgorithm.AES_GCM_NoPadding,
      enforceBiometrics: true,
      requireBiometricsPerOperation: true,
      biometricType: AndroidBiometricType.strongBiometricOnly,
      resetOnError: false,
      biometricPromptTitle: 'Desbloquear o cofre',
    ),
    iOptions: IOSOptions(
      accountName: 'keezy_vault_biometric_v1',
      accessibility: KeychainAccessibility.unlocked_this_device,
      accessControlFlags: [AccessControlFlag.biometryCurrentSet],
    ),
  );

  @override
  Future<String?> readPasswordEnvelope() => _ordinary.read(key: _passwordKey);

  @override
  Future<void> writePasswordEnvelope(String value) =>
      _ordinary.write(key: _passwordKey, value: value);

  @override
  Future<void> deletePasswordEnvelope() => _ordinary.delete(key: _passwordKey);

  @override
  Future<String?> readLegacyKey() => _ordinary.read(key: _legacyKey);

  @override
  Future<void> deleteLegacyKey() => _ordinary.delete(key: _legacyKey);

  @override
  Future<String?> readBiometricKey() => _biometric.read(key: _biometricKey);

  @override
  Future<void> writeBiometricKey(String value) =>
      _biometric.write(key: _biometricKey, value: value);

  @override
  Future<void> deleteBiometricKey() => _biometric.delete(key: _biometricKey);

  @override
  Future<String?> readDeletionMarker() => _ordinary.read(key: _deletionMarker);

  @override
  Future<void> writeDeletionMarker() =>
      _ordinary.write(key: _deletionMarker, value: 'empty');

  @override
  Future<void> deleteDeletionMarker() => _ordinary.delete(key: _deletionMarker);
}

class VaultKeyManager {
  static const int _version = 1;
  static const int _memoryKiB = 19456;
  static const int _iterations = 2;
  static const int _parallelism = 1;

  final VaultKeyStore store;
  final Random _random;

  VaultKeyManager({VaultKeyStore? store, Random? random})
    : store = store ?? DeviceVaultKeyStore(),
      _random = random ?? Random.secure();

  List<int> newDataKey() => _randomBytes(32);

  Future<List<int>?> passwordKey(String password) async {
    final encoded = await store.readPasswordEnvelope();
    if (encoded == null) return null;
    final envelope = jsonDecode(encoded) as Map<String, dynamic>;
    if (envelope['version'] != _version ||
        envelope['algorithm'] != 'argon2id-aes-256-gcm' ||
        envelope['memoryKiB'] != _memoryKiB ||
        envelope['iterations'] != _iterations ||
        envelope['parallelism'] != _parallelism) {
      throw const FormatException('Formato da chave do cofre desconhecido');
    }
    final salt = base64Decode(envelope['salt'] as String);
    final nonce = base64Decode(envelope['nonce'] as String);
    final cipherText = base64Decode(envelope['cipherText'] as String);
    final mac = base64Decode(envelope['mac'] as String);
    if (salt.length != 16 ||
        nonce.length != 12 ||
        cipherText.length != 32 ||
        mac.length != 16) {
      throw const FormatException('Credencial do cofre danificada');
    }
    final wrappingKey = await _derive(password, salt);
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: wrappingKey,
    );
    if (clear.length != 32) {
      throw const FormatException('Chave do cofre inválida');
    }
    return clear;
  }

  Future<List<int>?> legacyKey() async {
    final encoded = await store.readLegacyKey();
    if (encoded == null) return null;
    final key = base64Decode(encoded);
    if (key.length != 32) throw const FormatException('Chave antiga inválida');
    return key;
  }

  Future<void> protectWithPassword(String password, List<int> dataKey) async {
    if (password.isEmpty || dataKey.length != 32) {
      throw ArgumentError('Senha ou chave do cofre inválida');
    }
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final wrappingKey = await _derive(password, salt);
    final box = await AesGcm.with256bits().encrypt(
      dataKey,
      secretKey: wrappingKey,
      nonce: nonce,
    );
    await store.writePasswordEnvelope(
      jsonEncode({
        'version': _version,
        'algorithm': 'argon2id-aes-256-gcm',
        'memoryKiB': _memoryKiB,
        'iterations': _iterations,
        'parallelism': _parallelism,
        'salt': base64Encode(salt),
        'nonce': base64Encode(nonce),
        'cipherText': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      }),
    );
  }

  Future<List<int>?> biometricKey() async {
    final encoded = await store.readBiometricKey();
    if (encoded == null) return null;
    final key = base64Decode(encoded);
    if (key.length != 32) {
      throw const FormatException('Chave biométrica inválida');
    }
    return key;
  }

  Future<void> protectWithBiometrics(List<int> dataKey) async {
    if (dataKey.length != 32) {
      throw ArgumentError('Chave do cofre inválida');
    }
    await store.writeBiometricKey(base64Encode(dataKey));
  }

  Future<SecretKey> _derive(String password, List<int> salt) => Argon2id(
    memory: _memoryKiB,
    iterations: _iterations,
    parallelism: _parallelism,
    hashLength: 32,
  ).deriveKeyFromPassword(password: password, nonce: salt);

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));
}

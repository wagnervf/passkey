import 'dart:developer' as l;

import 'package:hive/hive.dart';
import 'package:keezy/src/core/hive/vault_key_manager.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/type_register/type_register_model.dart';

class RegisterHive {
  static const String boxName = 'registerBox';
  static const String oldBoxName = 'registerBox_old';

  static Box<RegisterModel>? _registerBox;
  static List<int>? _activeKey;
  static VaultKeyManager keyManager = VaultKeyManager();

  static bool get isUnlocked => _registerBox?.isOpen ?? false;
  static Box<RegisterModel> get _box {
    final box = _registerBox;
    if (box == null || !box.isOpen) throw StateError('Cofre bloqueado');
    return box;
  }

  /// Register adapters at startup without opening the encrypted box.
  static void init({VaultKeyManager? manager}) {
    if (manager != null) keyManager = manager;
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RegisterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TypeRegiterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InstalledAppModelAdapter());
    }
  }

  /// The caller must validate the master password before calling this method.
  static Future<void> unlockWithPassword(
    String password, {
    bool createIfMissing = false,
  }) async {
    if (password.isEmpty) throw ArgumentError('Senha vazia');
    if (isUnlocked) return;

    var key = await keyManager.passwordKey(password);
    final hasEnvelope = key != null;
    key ??= await keyManager.legacyKey();
    final hasLegacyKey = key != null && !hasEnvelope;

    if (key == null) {
      if (!createIfMissing || await Hive.boxExists(boxName)) {
        throw StateError('Chave do cofre indisponível');
      }
      key = keyManager.newDataKey();
      // Persist before creating a box: a failed write cannot strand a box.
      await keyManager.protectWithPassword(password, key);
    }

    try {
      await _open(key);
      if (hasLegacyKey) {
        // The old key survives if writing the password envelope fails.
        await keyManager.protectWithPassword(password, key);
      }
      if (hasLegacyKey || hasEnvelope) {
        try {
          await keyManager.store.deleteLegacyKey();
        } catch (_) {
          // Retried after the next password unlock.
        }
      }
    } catch (_) {
      await lock();
      rethrow;
    }
  }

  /// Reading the platform credential requires fresh biometric authentication.
  static Future<void> unlockWithBiometrics() async {
    if (isUnlocked) return;
    final key = await keyManager.biometricKey();
    if (key == null) throw StateError('Biometria não vinculada ao cofre');
    try {
      await _open(key);
    } catch (_) {
      await lock();
      rethrow;
    }
  }

  /// Upgrade path for installations whose biometric setting predates key binding.
  /// This must only be called after local_auth authenticates the user.
  static Future<void> unlockLegacyAfterBiometrics() async {
    if (isUnlocked) return;
    if (await keyManager.store.readPasswordEnvelope() != null) {
      throw StateError('Biometria não vinculada ao cofre');
    }
    final key = await keyManager.legacyKey();
    if (key == null) throw StateError('Chave antiga indisponível');
    try {
      await _open(key);
    } catch (_) {
      await lock();
      rethrow;
    }
  }

  static Future<void> _open(List<int> key) async {
    _registerBox = await Hive.openBox<RegisterModel>(
      boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    _activeKey = key;
    await migrateUnencrypted();
  }

  static Future<void> enableBiometrics() async {
    final key = _activeKey;
    if (key == null || !isUnlocked) throw StateError('Cofre bloqueado');
    await keyManager.protectWithBiometrics(key);
  }

  static Future<void> disableBiometrics() =>
      keyManager.store.deleteBiometricKey();

  static Future<void> lock() async {
    final box = _registerBox;
    _registerBox = null;
    _activeKey = null;
    if (box != null && box.isOpen) await box.close();
  }

  /// The marker lets deletion resume after a crash once the account is gone.
  static Future<void> markEmptyVaultForDeletion() async {
    if (!isUnlocked || _box.isNotEmpty) {
      throw StateError('O cofre deve estar aberto e vazio');
    }
    await keyManager.store.writeDeletionMarker();
  }

  static Future<void> completePendingDeletion() async {
    if (await keyManager.store.readDeletionMarker() != 'empty') return;
    await lock();
    await Hive.deleteBoxFromDisk(boxName);
    await keyManager.store.deletePasswordEnvelope();
    await keyManager.store.deleteLegacyKey();
    await keyManager.store.deleteBiometricKey();
    await keyManager.store.deleteDeletionMarker();
  }

  static Future<void> migrateUnencrypted() async {
    if (!await Hive.boxExists(oldBoxName)) return;
    final oldBox = await Hive.openBox<RegisterModel>(oldBoxName);
    if (oldBox.isEmpty) {
      await oldBox.deleteFromDisk();
      return;
    }
    for (final reg in oldBox.values) {
      await _box.put(reg.id, reg.copyWith());
    }
    // Delete only after all records were copied successfully.
    await oldBox.deleteFromDisk();
  }

  Future<bool> exists(String id) async => _box.containsKey(id);
  Future<void> addRegister(RegisterModel register) async =>
      _box.put(register.id, register);
  Future<void> updateRegister(RegisterModel register) async =>
      _box.put(register.id, register);
  Future<void> deleteRegister(String id) async => _box.delete(id);
  Future<void> clearAll() async => _box.clear();
  RegisterModel? getRegister(String id) => _box.get(id);
  List<RegisterModel> getAllRegisters() => _box.values.toList();

  Future<void> replaceAll(List<RegisterModel> list) async {
    await _box.clear();
    for (var reg in list) {
      await _box.put(reg.id, reg);
    }
  }

  int count() => _box.length;

  void debugPrintAll() {
    for (var item in _box.values) {
      l.log('REG: ${item.toString()}');
    }
  }
}

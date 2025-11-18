import 'dart:convert';
import 'dart:developer' as l;
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/type_register/type_register_model.dart';




class RegisterHive {
  static const String boxName = 'registerBox';
  static const String oldBoxName = 'registerBox_old';

  static late Box<RegisterModel> _registerBox;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _aesKeyName = 'keezy_aes_key_v1';

  // ============================================================
  // 1. Inicialização Principal
  // ============================================================
  static Future<void> init() async {
    final instance = RegisterHive();

    

    // Registrando Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RegisterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TypeRegiterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InstalledAppModelAdapter());
    }

    // Gera ou recupera chave AES
    final aesKey = await instance._getOrCreateAesKey();
    final cipher = HiveAesCipher(aesKey);

    // 🔐 Abre o BOX criptografado
    _registerBox = await Hive.openBox<RegisterModel>(
      boxName,
      encryptionCipher: cipher,
    );

    // 🔄 MIGRA DADOS ANTIGOS (caso existam)
    await migrateUnencrypted();
  }

  

  // ============================================================
  // 2. Criação/Recuperação da Chave AES
  // ============================================================
  Future<List<int>> _getOrCreateAesKey() async {
    final stored = await _secureStorage.read(key: _aesKeyName);

    if (stored != null) {
      return base64Decode(stored);
    }

    final newKey = List<int>.generate(32, (_) => Random.secure().nextInt(256));

    await _secureStorage.write(
      key: _aesKeyName,
      value: base64Encode(newKey),
    );

    return newKey;
  }

  // ============================================================
  // 3. Migração — do BOX antigo NÃO criptografado para o novo
  // ============================================================
  static Future<void> migrateUnencrypted() async {
    final exists = await Hive.boxExists(oldBoxName);

    if (!exists) {
      return; // nada para migrar
    }

    final oldBox = await Hive.openBox<RegisterModel>(oldBoxName);

    if (oldBox.isEmpty) {
      await oldBox.deleteFromDisk();
      return;
    }

    l.log("🔄 Iniciando migração de ${oldBox.length} registros...");

    for (final reg in oldBox.values) {
      await _registerBox.put(reg.id, reg);
    }

    // Apaga o box antigo para evitar duplicação
    await oldBox.clear();
    await oldBox.deleteFromDisk();

    l.log("✅ Migração concluída! Dados movidos com segurança.");
  }

  // ============================================================
  // 4. CRUD do Hive
  // ============================================================


  /// Verifica se um ID existe no banco
  Future<bool> exists(String id) async {
    return _registerBox.containsKey(id);
  }

  Future<void> addRegister(RegisterModel register) async {
    await _registerBox.put(register.id, register);
  }

  Future<void> updateRegister(RegisterModel register) async {
    await _registerBox.put(register.id, register);
  }

  Future<void> deleteRegister(String id) async {
    await _registerBox.delete(id);
  }

  Future<void> clearAll() async {
    await _registerBox.clear();
  }

  RegisterModel? getRegister(String id) {
    return _registerBox.get(id);
  }

  List<RegisterModel> getAllRegisters() {
    return _registerBox.values.toList();
  }

  Future<void> replaceAll(List<RegisterModel> list) async {
    await _registerBox.clear();
    for (var reg in list) {
      await _registerBox.put(reg.id, reg);
    }
  }

  int count() => _registerBox.length;

  void debugPrintAll() {
    for (var item in _registerBox.values) {
      l.log("REG: ${item.toString()}");
    }
  }
}

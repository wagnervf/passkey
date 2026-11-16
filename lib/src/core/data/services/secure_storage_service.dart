import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static late final FlutterSecureStorage _secureStorage;

  static void init() => _secureStorage = FlutterSecureStorage(
    
        aOptions: AndroidOptions(),
        iOptions: const IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

  Future<String> getDataKey(String key) async =>
      await _secureStorage.read(key: key) ?? '';

  Future<bool> hasApiKey(String key) async =>
      await _secureStorage.containsKey(key: key);

  Future<void> setDataKey(String key, String apikey) async =>
      await _secureStorage.write(key: key, value: apikey);

  Future<bool> saveStringList(String key, List<String> list) async {
    try {
      String encodedList = jsonEncode(list);
      await _secureStorage.write(key: key, value: encodedList);
      return true;
    } catch (_) {
      log('Erro ao salvar a lista.');
      return false; 
    }
  }

  Future<List<String>> getStringList(String key) async {
    try {
      String? encodedList = await _secureStorage.read(key: key);
      if (encodedList != null) {
        List<dynamic> decodedList = jsonDecode(encodedList);
        return decodedList.cast<String>();
      }
      return [];
    } catch (_) {
      log('Erro ao recuperar a lista.');
      return [];
    }
  }

  Future<void> deleteApiKey(String key) async =>
      await _secureStorage.delete(key: key);
  Future<void> deleteAll() async => await _secureStorage.deleteAll();
}

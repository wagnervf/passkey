import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static late final FlutterSecureStorage _secureStorage;

  static void init() => _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
        ),
      );

  Future<String> apiKey(String key) async =>
      await _secureStorage.read(key: key) ?? '';

  Future<bool> hasApiKey(String key) async =>
      await _secureStorage.containsKey(key: key);

  Future<void> setApiKey(String key, String apikey) async => await _secureStorage.write(
      key: key, value: apikey);

  Future<void> deleteApiKey(String key) async => await _secureStorage.delete(key: key);
}

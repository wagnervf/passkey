import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Verifies the master password without storing a recoverable copy of it.
class MasterPasswordVerifier {
  static const int version = 2;
  static const int memoryKiB = 19456;
  static const int iterations = 2;
  static const int parallelism = 1;
  static const int hashLength = 32;
  static const int saltLength = 16;

  final Random _random;

  MasterPasswordVerifier({Random? random})
    : _random = random ?? Random.secure();

  Future<Map<String, Object>> create(String password) async {
    if (password.isEmpty) {
      throw ArgumentError('A senha mestra não pode estar vazia');
    }

    final salt = List<int>.generate(saltLength, (_) => _random.nextInt(256));
    final hash = await _derive(password, salt);

    return {
      'version': version,
      'algorithm': 'argon2id',
      'memoryKiB': memoryKiB,
      'iterations': iterations,
      'parallelism': parallelism,
      'salt': base64Encode(salt),
      'hash': base64Encode(hash),
    };
  }

  Future<bool> verify(String password, Object? value) async {
    if (password.isEmpty || value is! Map<String, dynamic>) return false;

    try {
      if (value['version'] != version ||
          value['algorithm'] != 'argon2id' ||
          value['memoryKiB'] != memoryKiB ||
          value['iterations'] != iterations ||
          value['parallelism'] != parallelism) {
        return false;
      }

      final salt = base64Decode(value['salt'] as String);
      final expected = base64Decode(value['hash'] as String);
      if (salt.length != saltLength || expected.length != hashLength) {
        return false;
      }

      final actual = await _derive(password, salt);
      return _equalBytes(actual, expected);
    } on FormatException {
      return false;
    } on TypeError {
      return false;
    }
  }

  Future<List<int>> _derive(String password, List<int> salt) async {
    final algorithm = Argon2id(
      memory: memoryKiB,
      iterations: iterations,
      parallelism: parallelism,
      hashLength: hashLength,
    );
    final key = await algorithm.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return key.extractBytes();
  }

  bool _equalBytes(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var index = 0; index < a.length; index++) {
      difference |= a[index] ^ b[index];
    }
    return difference == 0;
  }
}

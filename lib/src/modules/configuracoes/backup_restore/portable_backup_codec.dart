import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class PortableBackup {
  const PortableBackup({required this.user, required this.registers});

  final AuthUserModel user;
  final List<RegisterModel> registers;
}

/// Versioned, password-protected format for backups that can be moved between
/// devices. It never stores the master password or a device-specific vault key.
class PortableBackupCodec {
  static const format = 'keezy-portable-backup';
  static const version = 1;
  static const _iterations = 600000;

  final Pbkdf2 _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );
  final Cipher _cipher = AesGcm.with256bits();
  final Random _random = Random.secure();

  Future<String> encode({
    required AuthUserModel user,
    required List<RegisterModel> registers,
    required String password,
  }) async {
    _validatePassword(password);
    final salt = _randomBytes(16);
    final nonce = _randomBytes(12);
    final key = await _deriveKey(password, salt);
    final payload = utf8.encode(
      jsonEncode({
        'user': {'name': user.name, 'email': user.email},
        'registers': registers.map((register) => register.toMap()).toList(),
      }),
    );
    final encrypted = await _cipher.encrypt(
      payload,
      secretKey: key,
      nonce: nonce,
    );

    return jsonEncode({
      'format': format,
      'version': version,
      'kdf': {
        'algorithm': 'pbkdf2-hmac-sha256',
        'iterations': _iterations,
        'salt': base64Encode(salt),
      },
      'cipher': {
        'algorithm': 'aes-256-gcm',
        'nonce': base64Encode(nonce),
        'ciphertext': base64Encode(encrypted.cipherText),
        'mac': base64Encode(encrypted.mac.bytes),
      },
    });
  }

  Future<PortableBackup> decode({
    required String encoded,
    required String password,
  }) async {
    _validatePassword(password);
    try {
      final document = jsonDecode(encoded);
      if (document is! Map<String, dynamic> ||
          document['format'] != format ||
          document['version'] != version) {
        throw const FormatException('Formato de backup incompatível.');
      }
      final kdf = document['kdf'];
      final cipher = document['cipher'];
      if (kdf is! Map<String, dynamic> || cipher is! Map<String, dynamic>) {
        throw const FormatException('Estrutura de backup inválida.');
      }
      if (kdf['algorithm'] != 'pbkdf2-hmac-sha256' ||
          kdf['iterations'] != _iterations ||
          cipher['algorithm'] != 'aes-256-gcm') {
        throw const FormatException('Algoritmos de backup incompatíveis.');
      }
      final salt = base64Decode(_string(kdf, 'salt'));
      final nonce = base64Decode(_string(cipher, 'nonce'));
      final ciphertext = base64Decode(_string(cipher, 'ciphertext'));
      final mac = base64Decode(_string(cipher, 'mac'));
      if (salt.length != 16 || nonce.length != 12 || mac.length != 16) {
        throw const FormatException('Parâmetros criptográficos inválidos.');
      }
      final plaintext = await _cipher.decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)),
        secretKey: await _deriveKey(password, salt),
      );
      final payload = jsonDecode(utf8.decode(plaintext));
      if (payload is! Map<String, dynamic> ||
          payload['user'] is! Map<String, dynamic> ||
          payload['registers'] is! List) {
        throw const FormatException('Conteúdo de backup inválido.');
      }
      final userData = payload['user'] as Map<String, dynamic>;
      final registerData = payload['registers'] as List<dynamic>;
      final registers = registerData.map((value) {
        if (value is! Map<String, dynamic>) {
          throw const FormatException('Registro de backup inválido.');
        }
        return RegisterModel.fromMap(value);
      }).toList();
      return PortableBackup(
        user: AuthUserModel(
          name: userData['name']?.toString() ?? '',
          email: userData['email']?.toString() ?? '',
        ),
        registers: registers,
      );
    } on SecretBoxAuthenticationError {
      throw const FormatException(
        'Senha de backup incorreta ou arquivo alterado.',
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Arquivo de backup inválido.');
    }
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) =>
      _kdf.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

  String _string(Map<String, dynamic> value, String key) {
    final result = value[key];
    if (result is! String || result.isEmpty) {
      throw const FormatException('Campo de backup ausente.');
    }
    return result;
  }

  void _validatePassword(String password) {
    if (password.length < 10) {
      throw const FormatException(
        'A senha de backup deve ter ao menos 10 caracteres.',
      );
    }
  }

  List<int> _randomBytes(int length) =>
      List<int>.generate(length, (_) => _random.nextInt(256));
}

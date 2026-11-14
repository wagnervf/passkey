import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptDecryptServices {
  // Read-only compatibility with credentials written before version 2.
  // Remove after all supported installations have migrated.
  static const _encryptionKey = 'my32lengthsupersecretnooneknows1';

  String decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromUtf8(_encryptionKey);

    // Separar o IV do texto criptografado
    final parts = encryptedPassword.split(':');
    if (parts.length != 2) {
      throw Exception('Dados criptografados inválidos');
    }

    final iv = encrypt.IV.fromBase64(parts[0]);
    final encryptedText = parts[1];

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt64(encryptedText, iv: iv);
  }

}

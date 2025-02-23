import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptDecryptServices {
  static const _encryptionKey = 'my32lengthsupersecretnooneknows1';


  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8(_encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);

    // Concatenar o IV com o texto criptografado
    return '${iv.base64}:${encrypted.base64}';
  }

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
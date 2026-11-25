import 'package:keezy/src/core/utils/secure_password_generator.dart';

class MasterPasswordPolicy {
  static const int minimumLength = 8;
  static const String guidance =
      'Use pelo menos 8 caracteres. Prefira uma senha longa e única.';

  static String? validate(String password) {
    if (password.trim().isEmpty) {
      return 'Informe uma senha mestra que não seja apenas espaços.';
    }
    if (password.runes.length < minimumLength) {
      return 'A senha mestra deve ter pelo menos 8 caracteres.';
    }
    return null;
  }

  static String generate({int length = 16}) {
    if (length < minimumLength) throw ArgumentError.value(length, 'length');
    return generateSecurePassword(length: length);
  }
}

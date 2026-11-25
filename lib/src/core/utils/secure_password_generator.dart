import 'dart:math';

String generateSecurePassword({int length = 16}) {
  if (length < 1) throw ArgumentError.value(length, 'length');
  const lower = 'abcdefghijklmnopqrstuvwxyz';
  const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const nums = '0123456789';
  const symbols = '!@#\$%&()=+[]{}|?';
  final all = lower + upper + nums + symbols;
  final random = Random.secure();
  return List.generate(length, (_) => all[random.nextInt(all.length)]).join();
}

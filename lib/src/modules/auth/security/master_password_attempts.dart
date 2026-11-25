import 'dart:convert';

import 'package:keezy/src/core/data/services/secure_storage_service.dart';

/// A temporary, persistent delay for local password guesses. No lock is permanent.
class MasterPasswordAttempts {
  static const _key = 'master_password_attempts_v1';
  final SecureStorageService storage;
  final DateTime Function() now;

  MasterPasswordAttempts({required this.storage, DateTime Function()? now})
    : now = now ?? DateTime.now;

  Future<Duration> remaining() async {
    final state = await _read();
    final until = state.$2;
    if (until == null) return Duration.zero;
    final wait = until.difference(now());
    return wait.isNegative ? Duration.zero : wait;
  }

  Future<Duration> recordFailure() async {
    final state = await _read();
    final failures = state.$1 + 1;
    final level = failures - 5;
    final seconds = level < 0 ? 0 : 30 * (1 << (level > 5 ? 5 : level));
    final delay = Duration(seconds: seconds > 900 ? 900 : seconds);
    final until = delay == Duration.zero ? null : now().add(delay);
    await storage.setDataKey(
      _key,
      jsonEncode({
        'failures': failures,
        'until': until?.millisecondsSinceEpoch,
      }),
    );
    return delay;
  }

  Future<void> clear() => storage.deleteApiKey(_key);

  Future<(int, DateTime?)> _read() async {
    try {
      final data = await storage.getDataKey(_key);
      if (data.isEmpty) return (0, null);
      final value = jsonDecode(data);
      if (value is! Map<String, dynamic>) return (0, null);
      final failures = value['failures'];
      final until = value['until'];
      if (failures is! int || failures < 0) return (0, null);
      return (
        failures,
        until is int ? DateTime.fromMillisecondsSinceEpoch(until) : null,
      );
    } on FormatException {
      return (0, null);
    }
  }
}

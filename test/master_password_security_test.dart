import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/modules/auth/security/master_password_attempts.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';

class _MemoryStorage extends SecureStorageService {
  final values = <String, String>{};

  @override
  Future<String> getDataKey(String key) async => values[key] ?? '';

  @override
  Future<void> setDataKey(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> deleteApiKey(String key) async {
    values.remove(key);
  }
}

void main() {
  test('generated suggestions meet the new password policy', () {
    final short = MasterPasswordPolicy.generate(length: 8);
    final long = MasterPasswordPolicy.generate(length: 16);
    expect(short.length, 8);
    expect(long.length, 16);
    expect(short, isNot(long));
    expect(MasterPasswordPolicy.validate(short), isNull);
    expect(MasterPasswordPolicy.validate(long), isNull);
    expect(MasterPasswordPolicy.validate('seis12'), isNotNull);
    expect(MasterPasswordPolicy.validate('oito1234'), isNull);
    expect(MasterPasswordPolicy.validate('            '), isNotNull);
  });

  test('temporary delays survive service recreation and expire', () async {
    final storage = _MemoryStorage();
    var time = DateTime(2026, 11, 25);
    MasterPasswordAttempts attempts() =>
        MasterPasswordAttempts(storage: storage, now: () => time);

    for (var i = 0; i < 4; i++) {
      expect(await attempts().recordFailure(), Duration.zero);
    }
    expect(await attempts().recordFailure(), const Duration(seconds: 30));
    expect(await attempts().remaining(), const Duration(seconds: 30));
    time = time.add(const Duration(seconds: 29));
    expect(await attempts().remaining(), const Duration(seconds: 1));
    time = time.add(const Duration(seconds: 1));
    expect(await attempts().remaining(), Duration.zero);
    expect(await attempts().recordFailure(), const Duration(seconds: 60));
    time = time.add(const Duration(minutes: 1));
    await attempts().clear();
    expect(await attempts().remaining(), Duration.zero);
    for (var i = 0; i < 4; i++) {
      expect(await attempts().recordFailure(), Duration.zero);
    }
    expect(await attempts().recordFailure(), const Duration(seconds: 30));
  });
}

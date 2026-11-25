import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/portable_backup_codec.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/type_register/type_register_model.dart';

void main() {
  const password = 'senha de backup segura';
  final codec = PortableBackupCodec();
  final registers = [
    RegisterModel(
      id: 'one',
      name: 'Site',
      username: 'ana',
      password: 'segredo',
      note: 'nota privada',
      isFavorite: true,
    ),
  ];

  test(
    'backup portátil restaura usuário e registros sem senha mestra',
    () async {
      final encoded = await codec.encode(
        user: AuthUserModel(
          name: 'Ana',
          email: 'ana@example.test',
          password: 'senha mestra que não deve aparecer',
        ),
        registers: registers,
        password: password,
      );

      expect(encoded, isNot(contains('senha mestra que não deve aparecer')));
      expect(encoded, isNot(contains('segredo')));
      final restored = await codec.decode(encoded: encoded, password: password);
      expect(restored.user.name, 'Ana');
      expect(restored.user.email, 'ana@example.test');
      expect(restored.user.password, isEmpty);
      expect(restored.registers, registers);
    },
  );

  test(
    'preserva ícone do aplicativo e categoria no backup',
    () async {
      final record = RegisterModel(
        id: 'com-app',
        name: 'Aplicativo',
        selectedApp: InstalledAppModel(
          id: 42,
          name: 'Exemplo',
          packageName: 'com.example.app',
          iconBytes: Uint8List.fromList([0, 1, 127, 255]),
        ),
        type: TypeRegiterModel(
          id: 3,
          name: 'Compras',
          icon: 'shopping',
          color: const Color(0xFF123456),
        ),
      );
      final encoded = await codec.encode(
        user: AuthUserModel(name: 'Ana'),
        registers: [record],
        password: password,
      );
      final restored = await codec.decode(encoded: encoded, password: password);
      final result = restored.registers.single;

      expect(result.selectedApp?.iconBytes, orderedEquals([0, 1, 127, 255]));
      expect(result.selectedApp?.packageName, 'com.example.app');
      expect(result.type?.color, const Color(0xFF123456));
      expect(result.type?.name, 'Compras');
    },
  );

  test(
    'backup usa sal e nonce novos e rejeita senha ou arquivo alterados',
    () async {
      final first = await codec.encode(
        user: AuthUserModel(name: 'Ana'),
        registers: registers,
        password: password,
      );
      final second = await codec.encode(
        user: AuthUserModel(name: 'Ana'),
        registers: registers,
        password: password,
      );
      expect(first, isNot(second));
      await expectLater(
        codec.decode(encoded: first, password: 'senha incorreta longa'),
        throwsFormatException,
      );

      final altered = jsonDecode(first) as Map<String, dynamic>;
      altered['cipher']['mac'] = base64Encode(List<int>.filled(16, 0));
      await expectLater(
        codec.decode(encoded: jsonEncode(altered), password: password),
        throwsFormatException,
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/views/backup_restore_page.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';

class _UnusedAuthController extends Fake implements AuthController {}

class _UnusedRegisterController extends Fake implements RegisterController {}

void main() {
  test('restauração indisponível não grava usuário nem anuncia sucesso', () async {
    final registers = _UnusedRegisterController();
    final controller = BackupRestoreController(registerControllerX: registers);
    addTearDown(controller.close);

    final message = await controller.restoreBackup(
      _UnusedAuthController(),
      registers,
    );

    expect(message, 'Restauração de backup Keezy ainda não disponível.');
    expect(controller.state, isA<BackupRestoreStateErrorState>());
    expect(
      (controller.state as BackupRestoreStateErrorState).message,
      message,
    );
  });

  testWidgets('tela de backup não oferece restauração incompleta', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BackupRestorePage())),
    );

    expect(find.text('Backup Keezy ainda não disponível'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/views/backup_restore_page.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/repositories/register_repository_impl.dart';
import 'package:provider/provider.dart';

class _BackupController extends BackupRestoreController {
  _BackupController()
    : super(
        registerController: RegisterController(
          registerRepository: RegisterRepositoryImpl(),
        ),
        authRepository: AuthRepository(),
      );

  String? receivedPassword;
  Completer<String?>? completion;
  Completer<String?>? importCompletion;
  bool importSucceeds = true;

  @override
  Future<String?> exportBackup(String password) {
    receivedPassword = password;
    return completion?.future ?? Future.value();
  }

  @override
  Future<String?> importBackupIntoCurrentVault(String password) async {
    receivedPassword = password;
    final message = await importCompletion!.future;
    emit(
      importSucceeds
          ? BackupRestoreStateSuccessState(message!)
          : BackupRestoreStateErrorState(message!),
    );
    return message;
  }
}

void main() {
  testWidgets('fecha o diálogo e inicia o backup após confirmar a senha', (
    tester,
  ) async {
    final controller = _BackupController();
    await tester.pumpWidget(
      Provider<BackupRestoreController>.value(
        value: controller,
        child: const MaterialApp(
          home: Scaffold(body: BackupRestorePage(showRestore: false)),
        ),
      ),
    );

    await tester.tap(find.text('Criar backup Keezy'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'senha-de-backup');
    await tester.enterText(find.byType(TextField).last, 'senha-de-backup');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(controller.receivedPassword, 'senha-de-backup');
    expect(find.text('Proteger backup'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await controller.registerController.close();
    await controller.close();
  });

  testWidgets('mostra progresso e confirma o backup mesmo após sair da tela', (
    tester,
  ) async {
    final controller = _BackupController()..completion = Completer<String?>();
    final onSettings = ValueNotifier(true);
    await tester.pumpWidget(
      Provider<BackupRestoreController>.value(
        value: controller,
        child: MaterialApp(
          home: ValueListenableBuilder<bool>(
            valueListenable: onSettings,
            builder: (_, visible, _) => Scaffold(
              body: visible
                  ? const BackupRestorePage(showRestore: false)
                  : const Text('Outra tela'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Criar backup Keezy'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'senha-de-backup');
    await tester.enterText(find.byType(TextField).last, 'senha-de-backup');
    await tester.tap(find.text('Continuar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('backup-progress')), findsOneWidget);
    expect(controller.receivedPassword, 'senha-de-backup');

    onSettings.value = false;
    await tester.pump();
    controller.completion!.complete(null);
    await tester.pump();
    expect(find.text('Backup compartilhado com sucesso.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    onSettings.dispose();
    await controller.registerController.close();
    await controller.close();
  });

  for (final succeeds in [true, false]) {
    testWidgets(
      'restauração mostra loader e resultado sem sair de Configurações: $succeeds',
      (tester) async {
        final controller = _BackupController()
          ..importCompletion = Completer<String?>()
          ..importSucceeds = succeeds;
        await tester.pumpWidget(
          Provider<BackupRestoreController>.value(
            value: controller,
            child: const MaterialApp(
              home: Scaffold(
                body: BackupRestorePage(
                  showExport: false,
                  showRestore: false,
                  showImport: true,
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Restaurar backup Keezy'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'senha-de-backup');
        await tester.tap(find.text('Continuar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byKey(const ValueKey('backup-progress')), findsOneWidget);

        final message = succeeds
            ? '2 registros restaurados.'
            : 'Senha incorreta.';
        controller.importCompletion!.complete(message);
        await tester.pump();
        expect(find.text('Restaurar backup Keezy'), findsOneWidget);
        expect(find.text(message), findsOneWidget);
        expect(find.byKey(const ValueKey('backup-progress')), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await controller.registerController.close();
        await controller.close();
      },
    );
  }
}

import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';
import 'package:keezy/src/core/session/session_manager.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/backup_merge_plan.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/portable_backup_codec.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupRestoreController extends Cubit<BackupRestoreState> {
  BackupRestoreController({
    required this.registerController,
    required this.authRepository,
    PortableBackupCodec? codec,
  }) : _codec = codec ?? PortableBackupCodec(),
       super(BackupRestoreStateInitialState());

  final RegisterController registerController;
  final AuthRepository authRepository;
  final PortableBackupCodec _codec;
  String? _pendingImportEncoded;

  Future<String?> exportBackup(String password) async {
    emit(BackupRestoreStateLoadingState());
    File? file;
    var stage = 'carregar perfil';
    developer.log('Criação iniciada.', name: 'keezy.backup');
    try {
      final user = await authRepository.getUser();
      stage = 'carregar registros';
      final registers = await registerController.getRegisterForExportCsv();
      if (user == null || registers == null || registers.isEmpty) {
        developer.log(
          'Dados indisponíveis: perfil=${user == null ? 'ausente' : 'presente'}, '
          'registros=${registers == null ? 'falha na leitura' : registers.length}.',
          name: 'keezy.backup',
        );
        const message = 'Não há registros para incluir no backup.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      stage = 'criptografar backup';
      final encoded = await _codec.encode(
        user: user,
        registers: registers,
        password: password,
      );
      stage = 'criar arquivo temporário';
      final directory = await getTemporaryDirectory();
      file = File(
        '${directory.path}/keezy_backup_${DateTime.now().microsecondsSinceEpoch}.keezy',
      );
      await file.writeAsString(encoded, flush: true);
      stage = 'compartilhar arquivo';
      developer.log(
        'Arquivo criado; abrindo compartilhamento.',
        name: 'keezy.backup',
      );
      final result = await SharePlus.instance.share(
        ShareParams(
          subject: 'Backup Keezy protegido',
          text: 'Backup Keezy protegido por senha.',
          files: [XFile(file.path)],
        ),
      );
      developer.log(
        'Compartilhamento retornou: ${result.status}.',
        name: 'keezy.backup',
      );
      if (result.status != ShareResultStatus.success) {
        const message = 'Compartilhamento cancelado ou não confirmado.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      developer.log('Backup compartilhado com sucesso.', name: 'keezy.backup');
      emit(BackupRestoreStateSuccessState('Backup compartilhado com sucesso.'));
      return null;
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'Formato inválido na etapa: $stage.',
        name: 'keezy.backup',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      emit(BackupRestoreStateErrorState(error.message));
      return error.message;
    } catch (error, stackTrace) {
      developer.log(
        'Falha na etapa: $stage.',
        name: 'keezy.backup',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      const message = 'Não foi possível criar o backup.';
      emit(BackupRestoreStateErrorState(message));
      return message;
    } finally {
      try {
        if (file != null && await file.exists()) await file.delete();
      } catch (error, stackTrace) {
        developer.log(
          'Falha ao remover arquivo temporário.',
          name: 'keezy.backup',
          error: error.runtimeType,
          stackTrace: stackTrace,
        );
      }
    }
  }

  Future<String?> restoreBackup({
    required AuthController authController,
    required String backupPassword,
    required String newMasterPassword,
  }) async {
    emit(BackupRestoreStateLoadingState());
    try {
      if (await authRepository.hasUser() ||
          await RegisterHive.hasPersistentVault()) {
        const message =
            'Para restaurar, exclua primeiro o cofre atual deste dispositivo.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      if (MasterPasswordPolicy.validate(newMasterPassword)
          case final message?) {
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      final selection = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['keezy'],
      );
      final path = selection?.path;
      if (path == null) {
        emit(BackupRestoreStateInitialState());
        return null;
      }
      final backup = await _codec.decode(
        encoded: await File(path).readAsString(),
        password: backupPassword,
      );
      if (backup.registers.isEmpty) {
        const message = 'O backup não contém registros para restaurar.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      final accountCreated = await authController.registerUser(
        AuthUserModel(
          name: backup.user.name,
          email: backup.user.email,
          password: newMasterPassword,
        ),
      );
      if (!accountCreated) {
        const message = 'Não foi possível preparar o novo cofre.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      final recordsSaved = await registerController.saveListRegistersController(
        backup.registers,
      );
      final restored = await registerController.getRegisterForExportCsv();
      final restoredIds =
          restored?.map((register) => register.id).toSet() ?? {};
      final expectedIds = backup.registers
          .map((register) => register.id)
          .toSet();
      if (!recordsSaved ||
          restoredIds.length != expectedIds.length ||
          !restoredIds.containsAll(expectedIds)) {
        final removed = await authController.logoutAndRemoveUser();
        final message = removed
            ? 'A restauração falhou e o novo cofre foi removido.'
            : 'A restauração falhou. Exclua o novo cofre antes de tentar novamente.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      emit(
        BackupRestoreStateSuccessState(
          '${backup.registers.length} registros restaurados com sucesso.',
        ),
      );
      return null;
    } on FormatException catch (error) {
      emit(BackupRestoreStateErrorState(error.message));
      return error.message;
    } catch (_) {
      const message = 'Não foi possível restaurar este backup.';
      emit(BackupRestoreStateErrorState(message));
      return message;
    }
  }

  /// Imports a protected backup into an unlocked vault without replacing data.
  Future<String?> importBackupIntoCurrentVault(String backupPassword) async {
    emit(BackupRestoreStateLoadingState());
    var stage = 'selecionar arquivo';
    try {
      if (!RegisterHive.isUnlocked) {
        const message = 'Desbloqueie o cofre antes de restaurar o backup.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      var encoded = _pendingImportEncoded;
      if (encoded == null) {
        String? path;
        SessionManager.beginSystemPicker();
        try {
          final selection = await FilePicker.pickFile(
            type: FileType.custom,
            allowedExtensions: ['keezy'],
          );
          path = selection?.path;
        } finally {
          SessionManager.endSystemPicker();
        }
        if (path == null) {
          emit(BackupRestoreStateInitialState());
          return null;
        }
        stage = 'ler arquivo selecionado';
        encoded = await File(path).readAsString();
      }
      if (!RegisterHive.isUnlocked) {
        _pendingImportEncoded = encoded;
        const message =
            'Arquivo selecionado. Desbloqueie o cofre e volte '
            'a Configurações para concluir a restauração.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      stage = 'descriptografar backup';
      final backup = await _codec.decode(
        encoded: encoded,
        password: backupPassword,
      );
      if (!RegisterHive.isUnlocked) {
        _pendingImportEncoded = encoded;
        const message =
            'Cofre bloqueado. Desbloqueie e tente restaurar novamente.';
        emit(BackupRestoreStateErrorState(message));
        return message;
      }
      stage = 'comparar registros';
      final current = await registerController.getRegisterForExportCsv();
      if (current == null) {
        throw StateError('Não foi possível ler o cofre atual');
      }
      final plan = BackupMergePlan(
        current: current,
        imported: backup.registers,
      );
      if (plan.toImport.isEmpty) {
        _pendingImportEncoded = null;
        const message = 'Nenhum registro novo no backup.';
        emit(BackupRestoreStateSuccessState(message));
        return message;
      }
      stage = 'salvar registros';
      final saved = await registerController.addNewRegistersController(
        plan.toImport,
      );
      stage = 'confirmar registros salvos';
      final verified = await registerController.getRegisterForExportCsv();
      final byId = {
        for (final record in verified ?? <RegisterModel>[]) record.id: record,
      };
      if (!saved ||
          verified == null ||
          !plan.toImport.every((record) {
            final actual = byId[record.id];
            return actual != null &&
                BackupMergePlan.sameContent(actual, record);
          })) {
        throw StateError('Não foi possível confirmar todos os registros');
      }
      final message =
          '${plan.toImport.length} registro(s) restaurado(s); '
          '${plan.duplicates} repetido(s) ignorado(s).';
      _pendingImportEncoded = null;
      emit(BackupRestoreStateSuccessState(message));
      return message;
    } on FormatException catch (error, stackTrace) {
      _pendingImportEncoded = null;
      developer.log(
        'Falha na restauração: $stage.',
        name: 'keezy.backup',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      emit(BackupRestoreStateErrorState(error.message));
      return error.message;
    } catch (error, stackTrace) {
      developer.log(
        'Falha na restauração: $stage.',
        name: 'keezy.backup',
        error: error.runtimeType,
        stackTrace: stackTrace,
      );
      const message =
          'Restauração interrompida. Registros existentes foram mantidos. '
          'Selecione o mesmo backup para concluir.';
      emit(BackupRestoreStateErrorState(message));
      return message;
    }
  }
}

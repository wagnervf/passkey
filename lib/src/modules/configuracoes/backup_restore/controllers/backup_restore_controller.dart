// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passkey/src/core/components/encrypt/encrypt_decrypt_services.dart';
import 'package:passkey/src/core/data/services/secure_storage_service.dart';
import 'package:passkey/src/core/either/either.dart';
import 'package:passkey/src/core/exceptions/repository_exception.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';
import 'package:passkey/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupRestoreController extends Cubit<BackupRestoreState> {
  BackupRestoreController({required this.registerControllerX})
      : super(BackupRestoreStateInitialState());

  static const _keyRegistros = 'registers';

  static const _userKey = 'auth_user';

  final secureStorageService = SecureStorageService();
  final encrypt = EncryptDecryptServices();
  final RegisterController registerControllerX;

  /// Obtém a lista de registros armazenados
  Future<List<RegisterModel>> _getListRegister() async {
    try {
      final List<String>? registrosString =
          await secureStorageService.getStringList(_keyRegistros);

      if (registrosString == null || registrosString.isEmpty) {
        return [];
      }

      return registrosString
          .map(
            (registro) => RegisterModel.fromMap(jsonDecode(registro)),
          )
          .toList();
    } catch (e, s) {
      log("Erro ao buscar registros: $e", error: e, stackTrace: s);
      return [];
    }
  }

  // Buscar o usuário para exportá-lo
  Future<AuthUserModel?> getUser() async {
    final userData = await secureStorageService.getDataKey(_userKey);

    if (userData == '') return null;

    try {
      final jsonUser = json.decode(userData);

      final encryptedPassword = jsonUser['password']?.toString();
      if (encryptedPassword == null) {
        throw Exception('Senha ausente ou inválido no JSON');
      }

      // Descriptografar a senha
      final decryptedPassword = encrypt.decryptPassword(encryptedPassword);

      final user = AuthUserModel(
        name: jsonUser['name']?.toString() ?? '',
        email: jsonUser['email']?.toString() ?? '',
        password: decryptedPassword,
      );

      return user;
    } catch (e) {
      log('Erro ao recuperar o usuário: $e');
      return null;
    }
  }

  Future<String> exportBackup() async {
    emit(BackupRestoreStateLoadingState());

    try {
      AuthUserModel? user = await getUser();

      if (user == null || user.name.isEmpty) {
        log('Usuário não encontrado para exportação.');
        return 'Usuário não encontrado para exportação.';
      }

      final List<RegisterModel> registros = await _getListRegister();

      if (registros.isEmpty) {
        log('Nenhum registro encontrado para exportação.');
        return 'Nenhum registro encontrado para exportação.';
      }

      final String jsonRegister =
          jsonEncode(registros.map((r) => r.toJson()).toList());

      final String userJson = jsonEncode(user.toJson());

      final String dataExport =
          jsonEncode({_userKey: userJson, _keyRegistros: jsonRegister});

      log("Dados exportados: $dataExport");

      // Obtendo diretório
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/passkey_backup.json';
      final File file = File(filePath);

      await file.writeAsString(dataExport);

      // Compartilhando o arquivo
      final ShareResult result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Segue o backup dos dados do meu aplicativo!',
      );

      file.existsSync();
      emit(BackupRestoreStateSuccessState());

      log('Compartilhamento: $result');
      log('Backup exportado com sucesso! Arquivo salvo em: $filePath');
      return 'Backup exportado com sucesso!';
    } catch (e, s) {
      emit(BackupRestoreStateErrorState("Erro ao exportar backup: $e"));
      log("Erro ao exportar backup: $e", error: e.toString(), stackTrace: s);
      return "Erro ao exportar backup: $e";
    }
  }

  Future<String?> restoreBackup(AuthController authController,
      RegisterController registerController) async {
    try {
      emit(BackupRestoreStateLoadingState());

      final resultado = await importarViaArquivo();

      if (resultado != null) {
        AuthUserModel user = resultado['user'];
        List<RegisterModel> registros = resultado['registros'];

        log('Usuário importado: ${user.name}, ${user.email}');
        log('Registros importados: ${registros.length}');

        // Salvar usuário corretamente via AuthController
        await authController.registerUser(user);
        await registerControllerX.saveListRegisterController(registros);
        emit(BackupRestoreStateSuccessState());

        return 'Usuário importado!';

        // Salvar registros corretamente via RegisterController
        //  await registerController.importRegisters(registros);
      } else {
        log('Falha ao importar os dados.');
        
        emit(BackupRestoreStateErrorState('Falha ao importar os dados.'));
        return 'Falha ao importar os dados.';
      }
    } catch (e) {
      emit(BackupRestoreStateErrorState("Erro ao exportar backup: $e"));
      return "Erro ao exportar backup: $e";
    }
  }

  Future<Map<String, dynamic>?> importarViaArquivo() async {
    try {
      // Selecionar o arquivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        log("Nenhum arquivo selecionado.");
        return null;
      }

      final File file = File(result.files.single.path!);
      final String fileContent = await file.readAsString();

      // Decodificar o JSON
      final Map<String, dynamic> dataMap = jsonDecode(fileContent);

      // Validar a estrutura do JSON
      if (!dataMap.containsKey(_userKey) ||
          !dataMap.containsKey(_keyRegistros)) {
        log("Formato de arquivo inválido.");
        return null;
      }

      // Decodificar o usuário
      final AuthUserModel user =
          AuthUserModel.fromJson(jsonDecode(dataMap[_userKey]));

      // Decodificar os registros
      final List<dynamic> registrosJson = jsonDecode(dataMap[_keyRegistros]);
      final List<RegisterModel> registros =
          registrosJson.map((r) => RegisterModel.fromJson(r)).toList();

      log("Importação concluída com sucesso!");
      log("Usuário: ${user.name}, ${user.email}, ${user.password}");
      log("Registros: ${registros.length}");
      log("Registros: ${registros.first.description}");

      //bool userImported = await _saveUserImported(user);
      // return userImported ? 'Usuário importado' : 'Erro ao importar';
      return {
        'user': user,
        'registros': registros,
      };
    } catch (e, s) {
      log("Erro ao importar arquivo: $e", error: e.toString(), stackTrace: s);
      return null;
    }
  }

  Future<bool> exportarUmRegistro(RegisterModel registro) async {
    try {
      final String jsonContent = jsonEncode(registro.toJson());

      await Share.share(
        jsonContent,
        subject: 'Compartilhamento de Registro',
      );

      log('Registro compartilhado com sucesso!');
      return true;
    } catch (e, s) {
      log("Erro ao exportar registro: $e", error: e, stackTrace: s);
      return false;
    }
  }

  /// Importa um único registro a partir de um arquivo JSON
  Future<Either<RepositoryException, bool>> importarUmRegistro() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione um arquivo JSON contendo um único registro',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        log('Importação cancelada pelo usuário.');
        return Left(
            RepositoryException(message: 'Importação cancelada pelo usuário.'));
      }

      final String filePath = result.files.single.path!;
      final File file = File(filePath);
      final String jsonContent = await file.readAsString();
      final Map<String, dynamic> registroJson = jsonDecode(jsonContent);

      final RegisterModel registro = RegisterModel.fromMap(registroJson);

      final List<RegisterModel> listRegisters = await _getListRegister();
      listRegisters.add(registro);

      final sucesso = await _saveRegistersImported(listRegisters);

      if (sucesso) {
        log('Registro importado com sucesso!');
        return Right(true);
      } else {
        return Left(RepositoryException(
            message: 'Falha ao salvar o registro importado.'));
      }
    } catch (e, s) {
      log("Erro ao importar registro: $e", error: e, stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao importar o registro.'));
    }
  }

  Future<bool> _saveRegistersImported(List<RegisterModel> listRegisters) async {
    try {
      final List<String> registrosString =
          listRegisters.map((reg) => jsonEncode(reg.toMap())).toList();

      await secureStorageService.saveStringList(_keyRegistros, registrosString);

      return true;
    } catch (e, s) {
      log("Erro ao salvar registros localmente: $e", error: e, stackTrace: s);
      return false;
    }
  }

  // Future<bool> _saveUserImported(AuthUserModel user) async {
  //   if (user.name == '') return false;

  //   final encryptedPassword = encrypt.encryptPassword(user.password);
  //   final userToSave = {
  //     'name': user.name,
  //     'email': user.email,
  //     'password': encryptedPassword,
  //   };
  //   await secureStorageService.setDataKey(_userKey, json.encode(userToSave));
  //   return true;
  // }

  getTemporaryDirectory() {}
}

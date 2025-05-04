// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/encrypt/encrypt_decrypt_services.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/registro_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupRestoreController extends Cubit<BackupRestoreState> {
  BackupRestoreController({required this.registerControllerX})
      : super(BackupRestoreStateInitialState());

  static const _keyRegistros = 'registers';
  static const _userKey = 'auth_user';

  final secureStorageService = SecureStorageService();
  final encryptP = EncryptDecryptServices();
  final RegisterController registerControllerX;

   /// 🔐 Função para criptografar os dados
  String _encryptData(String plainText) {
    final key = encrypt.Key.fromUtf8(
        '0123456789abcdef0123456789abcdef'); // Chave de 32 bytes
    final iv = encrypt.IV.fromLength(16); // IV de 16 bytes
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return base64Encode(iv.bytes + encrypted.bytes); // Concatenamos IV + dados
  }

/// 🔓 Função para descriptografar os dados
  String _decryptData(String encryptedText) {
    final key = encrypt.Key.fromUtf8(
        '0123456789abcdef0123456789abcdef'); // Chave de 32 bytes
    final encryptedBytes = base64Decode(encryptedText);

    final iv = encrypt.IV(Uint8List.fromList(
        encryptedBytes.sublist(0, 16))); // Primeiro 16 bytes são o IV
    final encryptedData =
        encrypt.Encrypted(Uint8List.fromList(encryptedBytes.sublist(16)));

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt(encryptedData, iv: iv);
  }

  


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
      final decryptedPassword = encryptP.decryptPassword(encryptedPassword);

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

      // 🔐 Criptografando os dados
      final String encryptedData = _encryptData(dataExport);

      // Obtendo diretório
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/keezy_backup.enc';
      final File file = File(filePath);

      await file.writeAsString(encryptedData);

      // Compartilhando o arquivo
      final ShareResult result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Segue o backup criptografado dos dados do meu aplicativo!',
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
     // name	url	username	password	note


      final resultado = await _importarViaArquivo();

      if (resultado != null) {
        AuthUserModel user = resultado['user'];
        List<RegisterModel> registros = resultado['registros'];

        log('Usuário importado: ${user.name}, ${user.email}');
        log('Registros importados: ${registros.length}');

        // Salvar usuário corretamente via AuthController
        await authController.registerUser(user);
        await registerController.saveListRegisterController(registros);

        emit(BackupRestoreStateSuccessState());

        return 'Usuário importado!';
      } else {
        log('Falha ao importar os dados.');
        emit(BackupRestoreStateErrorState('Falha ao importar os dados.'));
        return 'Falha ao importar os dados.';
      }
    } catch (e) {
      emit(BackupRestoreStateErrorState("Erro ao importar backup: $e"));
      return "Erro ao importar backup: $e";
    }
  }

  Future<Map<String, dynamic>?> _importarViaArquivo() async {
    try {
      // Selecionar o arquivo criptografado
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['enc'], // Arquivo encriptado
      // );

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione um arquivo',
        type: FileType.any, // ✅ Permite qualquer arquivo
      );

      if (result == null || result.files.single.path == null) {
        log("Nenhum arquivo selecionado.");
        return null;
      }

      final File file = File(result.files.single.path!);
      final String encryptedContent = await file.readAsString();

      // 🔓 Descriptografar os dados
      final String decryptedData = _decryptData(encryptedContent);

      // Decodificar o JSON
      final Map<String, dynamic> dataMap = jsonDecode(decryptedData);

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
      log("Usuário: ${user.name}, ${user.email}");
      log("Registros: ${registros.length}");

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

      // 🔐 Criptografando os dados
      final String encryptedData = _encryptData(jsonContent);

      // Obtendo diretório
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/registro_backup.json';
      final File file = File(filePath);

      await file.writeAsString(encryptedData);

      // Compartilhando o arquivo
      final ShareResult result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Segue o backup criptografado do registro selecionado!',
      );

      file.existsSync();
      emit(BackupRestoreStateSuccessState());

      log('Compartilhamento: $result');
      log('Registro exportado com sucesso! Arquivo salvo em: $filePath');
      return true;
    } catch (e, s) {
      log("Erro ao exportar registro: $e", error: e, stackTrace: s);
      emit(BackupRestoreStateErrorState("Erro ao exportar registro: $e"));
      return false;
    }
  }

  /// Importa um único registro a partir de um arquivo JSON
  Future<Either<RepositoryException, bool>> importarUmRegistro() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione um arquivo',
        type: FileType.any, // ✅ Permite qualquer arquivo
      );

      if (result == null || result.files.single.path == null) {
        log("Nenhum arquivo selecionado.");
        return Left(RepositoryException(message: 'Nenhum arquivo selecionado.'));
      }

      final File file = File(result.files.single.path!);
      final String encryptedContent = await file.readAsString();

      // 🔓 Descriptografar os dados
      final String decryptedData = _decryptData(encryptedContent);

      // Decodificar o JSON
      final Map<String, dynamic> dataMap = jsonDecode(decryptedData);

      // Validar a estrutura do JSON
      if (!dataMap.containsKey('id') || !dataMap.containsKey('name')) {
        log("Formato de arquivo inválido.");
        return Left(RepositoryException(message: 'Formato de arquivo inválido.'));
      }

      // Decodificar o registro
      final RegisterModel registro = RegisterModel.fromJson(dataMap as String);

      // Salvar o registro importado
      final sucesso = await _saveOneRegisterImported(registro);

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

  Future<bool> _saveOneRegisterImported(RegisterModel registro) async {
    try {
      final List<RegisterModel> registros = await _getListRegister();
      registros.add(registro);

      final List<String> registrosString =
          registros.map((reg) => jsonEncode(reg.toMap())).toList();

      await secureStorageService.saveStringList(_keyRegistros, registrosString);

      return true;
    } catch (e, s) {
      log("Erro ao salvar registro localmente: $e", error: e, stackTrace: s);
      return false;
    }
  }

 
Future<List<Map<String, String>>> importCsv() async {
  try {
    // Permitir que o usuário selecione o arquivo CSV
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Selecione um arquivo CSV',
      type: FileType.custom,
      allowedExtensions: ['csv'], // Apenas arquivos CSV
    );

    if (result == null || result.files.single.path == null) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    final File file = File(result.files.single.path!);

    if (!await file.exists()) {
      throw Exception('Arquivo CSV não encontrado: ${file.path}');
    }

    final csvContent = await file.readAsString();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(
      csvContent,
      eol: '\n', // Define o separador de linhas
    );

    if (rows.isEmpty) {
      throw Exception('O arquivo CSV está vazio.');
    }

    // A primeira linha do CSV deve conter os cabeçalhos
    final headers = rows.first.map((header) => header.toString()).toList();
    final dataRows = rows.skip(1); // Ignora a linha de cabeçalhos

    // Converte as linhas em uma lista de mapas
    final List<Map<String, String>> data = dataRows.map((row) {
      final Map<String, String> rowData = {};
      for (int i = 0; i < headers.length; i++) {
        rowData[headers[i]] = row[i]?.toString() ?? '';
      }
      return rowData;
    }).toList();

    for (var row in data) {
      print('Name: ${row['name']}, URL: ${row['url']}, Username: ${row['username']}, Password: ${row['password']}, Note: ${row['note']}');
    }

    return data;
  } catch (e) {
    rethrow;
  }
}


}
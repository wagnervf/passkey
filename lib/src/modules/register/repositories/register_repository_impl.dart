import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:passkey/src/core/either/either.dart';
import 'package:passkey/src/core/exceptions/repository_exception.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
import 'package:passkey/src/modules/register/repositories/register_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  // late final RestClient restClient;

  RegisterRepositoryImpl();
  List<RegisterModel> allRegisters = [];
  static const _keyRegistros = 'registros';

  Future<List<RegisterModel>> getListRegister() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? registrosString = prefs.getStringList(_keyRegistros);

    if (registrosString == null) {
      return [];
    }

    return registrosString
        .map((registroString) =>
            RegisterModel.fromMap(jsonDecode(registroString)))
        .toList();
  }

  @override
  Future<Either<RepositoryException, List<RegisterModel>>>
      getAllRegisterRepository() async {
    try {
      var listRegisters = await getListRegister();

      if (listRegisters.isEmpty) {
        return Right([]);
      }

      return Right(listRegisters);
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      return Left(RepositoryException(
        message: 'Erro de conexão ao buscar os Register',
      ));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> saveRegisterRepository(
      RegisterModel register) async {
    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();
      var listRegisters = await getListRegister();

      listRegisters.add(register);

      var result = await salvarLocalmente(listRegisters);

      return Right(result);
    } catch (e, s) {
      log('Erro ao salvar registros: $e', error: e, stackTrace: s);
      return Left(RepositoryException(
        message: 'Erro ao salvar os registros.',
      ));
    }
  }

  salvarLocalmente(List<RegisterModel> listRegisters) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> registrosStringAtualizado =
        listRegisters.map((registro) => jsonEncode(registro.toMap())).toList();

    return await prefs.setStringList(_keyRegistros, registrosStringAtualizado);
  }

  @override
  Future<Either<RepositoryException, bool>> updateRegisterRepository(
      RegisterModel registro) async {
    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();
      var listRegisters = await getListRegister();
      //  print(listRegisters.toString());
      //  print(registro.id.toString());

      // Encontrar o índice do registro a ser atualizado
      int index = listRegisters.indexWhere((reg) => reg.id == registro.id);

      if (index != -1) {
        // Substituir o registro antigo pelo novo
        listRegisters[index] = registro;

        // List<String> registrosStringAtualizado = listRegisters
        //     .map((registro) => jsonEncode(registro.toMap()))
        //     .toList();

        // await prefs.setStringList(_keyRegistros, registrosStringAtualizado);
        var result = await salvarLocalmente(listRegisters);

        return Right(result);
      } else {
        return Left(RepositoryException(
          message: 'Erro ao atualizar registro',
        ));
      }

      // return Right(true);
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      return Left(RepositoryException(
        message: 'Erro ao atualizar registro',
      ));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> deleteRegisterRepository(
      RegisterModel registro) async {
    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();
      var listRegisters = await getListRegister();
      //  print(listRegisters.toString());
      //  print(registro.id.toString());

      // Encontrar o índice do registro a ser atualizado
      int index = listRegisters.indexWhere((reg) => reg.id == registro.id);

      if (index != -1) {
        // Substituir o registro antigo pelo novo
        //listRegisters[index] = registro;

        listRegisters.remove(listRegisters[index]);

        // List<String> registrosStringAtualizado = listRegisters
        //     .map((registro) => jsonEncode(registro.toMap()))
        //     .toList();

        // await prefs.setStringList(_keyRegistros, registrosStringAtualizado);
        var result = await salvarLocalmente(listRegisters);

        return Right(result);
      } else {
        return Left(RepositoryException(
          message: 'Erro ao remover o registro',
        ));
      }
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      return Left(RepositoryException(
        message: 'Erro ao remover o registro',
      ));
    }
  }




// TODO: Melhorar, revisão possiveis erros
  @override
  Future<ShareResultStatus> exportarViaArquivoRepository() async {
    try {
      List<RegisterModel> registros = await getListRegister();

      String jsonContent =
          jsonEncode(registros.map((r) => r.toJson()).toList());

      // Cria um arquivo temporário no diretório de documentos
      Directory directory = await getTemporaryDirectory();
      File file = File('${directory.path}/passkey_backup.json');

      await file.writeAsString(jsonContent);

      ShareResult result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Segue o backup dos dados do meu aplicativo!',
      );
      log('Backup realizado com sucesso!');

      return result.status;
    } catch (e) {
      log(e.toString());

      return ShareResultStatus.unavailable;
    }
  }

  @override
  Future<Either<RepositoryException, bool>>
      importarViaArquivoRepository() async {
    try {
      // Permite que o usuário selecione o arquivo JSON
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione o arquivo de backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        File file = File(filePath);

        // Lê e decodifica o conteúdo do arquivo JSON
        String jsonContent = await file.readAsString();
        List<dynamic> registrosJson = jsonDecode(jsonContent);

        var listRegisters = registrosJson
            .map((registrosJson) =>
                RegisterModel.fromMap(jsonDecode(registrosJson)))
            .toList();

        var registro = await salvarLocalmente(listRegisters);

        log('Dados importados com sucesso!');

        return Right(registro);
      } else {
        log('Importação cancelada pelo usuário.');

        return Left(RepositoryException(
          message: 'Importação cancelada pelo usuário.',
        ));
      }
    } catch (e) {
      log('Erro ao importar dados: $e');
      return Left(RepositoryException(
        message: 'Erro ao importar dados:',
      ));
    }
  }

  @override
  Future<bool> exportarUmRegistroRepository(RegisterModel registro) async {
    try {
      // Converte o registro para JSON
      String jsonContent = jsonEncode(registro.toJson());

      // Compartilha o registro JSON como texto
      await Share.share(
        jsonContent,
        subject: 'Compartilhamento de Registro',
      );
      
      log('Registro compartilhado com sucesso!');

      return true;
    } catch (e) {
      log('Erro ao compartilhar registro: $e');
      return false;
    }
  }
  
  @override
  Future<Either<RepositoryException, bool>> importarUmRegistroRepository() {
    // TODO: implement importarUmRegistroRepository
    throw UnimplementedError();
  }
}

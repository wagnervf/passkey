import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';


// TODO: Melhorar, revisão possiveis erros
Future<List<RegisterModel>> importarDadosViaArquivo() async {
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

      return registrosJson
          .map((registrosJson) =>
              RegisterModel.fromMap(jsonDecode(registrosJson)))
          .toList();
    } else {
      log('Importação cancelada pelo usuário.');
      return [];
    }
  } catch (e) {
    log('Erro ao importar dados: $e');
    return [];
  }
}

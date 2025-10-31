import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:path_provider/path_provider.dart';

class ImportRegistersCsvRepositoryImpl implements ImportRegistersCsvRepository {
  @override
  Future<List<RegisterModel>> importFromCsv(File file) async {
    try {
      if (!await file.exists()) {
        throw Exception('Arquivo CSV não encontrado');
      }

      final csvString = await file.readAsString();

      final csvTable = const CsvToListConverter(
        fieldDelimiter: ',',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(csvString);

      if (csvTable.isEmpty) {
        throw Exception('Arquivo CSV vazio.');
      }

      final header =
          csvTable.first.map((e) => e.toString().trim().toLowerCase()).toList();

      const requiredHeaders = ['name', 'url', 'username', 'password', 'note'];

      final missingColumns =
          requiredHeaders.where((h) => !header.contains(h)).toList();
      if (missingColumns.isNotEmpty) {
        // throw Exception('Colunas ausentes no CSV: ${missingColumns.join(', ')}');
        throw Exception(
            'Verifique se o arquivo CSV possui as coluns corretas e tente novamente');
      }

      final dataRows = csvTable.skip(1).toList();
      if (dataRows.isEmpty) {
        throw Exception(
            'Verifique se o arquivo CSV possui dados e tente novamente');
      }

      final entries =
          dataRows.map((row) => RegisterModel.fromCsv(row)).toList();

      return entries;
    } catch (e) {
      
      log(e.toString());
      return [];
    }
  }


 
@override
  Future<File> exportToCsv(List<RegisterModel> registros) async {
  try {
    if (registros.isEmpty) {
      throw Exception('Nenhum dado disponível para exportar.');
    }

    // Cabeçalho
    const headers = ['name', 'url', 'username', 'password', 'note'];

    // Conteúdo dos registros
    final rows = registros.map((e) => [
          e.name,
          e.url,
          e.username,
          e.password,
          e.note,
        ]).toList();

    final csvData = const ListToCsvConverter().convert([headers, ...rows]);

    // Diretório para salvar (temporário ou externo)
    final dir = await getTemporaryDirectory(); // você pode trocar por outro
    final file = File('${dir.path}/exported_registers.csv');

    await file.writeAsString(csvData);

    return file;
  } catch (e) {
    log('Erro ao exportar CSV: $e');
    rethrow;
  }
}

}

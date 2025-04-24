import 'dart:io';

import 'package:csv/csv.dart';
import 'package:passkey/src/modules/import_registers_csv/repositories/import_registers_csv_repository.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';

class ImportRegistersCsvRepositoryImpl implements ImportRegistersCsvRepository {
  @override
  Future<List<RegisterModel>> importFromCsv(File file) async {
    // Verifica se o arquivo existe
    if (!await file.exists()) {
      throw Exception('Arquivo CSV não encontrado');
    }    

    final csvString = await file.readAsString();
    final csvTable = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);
    // Verifica se o arquivo CSV está vazio
    if (csvTable.isEmpty) {
      throw Exception('Arquivo CSV vazio');
    }

    // Verifica se o arquivo CSV tem cabeçalho
    if (csvTable.first.isEmpty) {
      throw Exception('Arquivo CSV sem cabeçalho');
    }
    
    // Verfica se o arquivo está no formato correto
    

    final rows = csvTable.skip(1).toList();
    return rows.map((row) => RegisterModel.fromCsv(row)).toList();
  }
}

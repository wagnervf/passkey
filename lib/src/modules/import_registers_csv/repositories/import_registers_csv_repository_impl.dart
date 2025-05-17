import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

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

      if (csvTable == null) {
      return [];
      }

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
}

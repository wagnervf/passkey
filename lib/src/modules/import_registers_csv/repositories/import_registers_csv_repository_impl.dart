import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:uuid/uuid.dart';


class ImportRegistersCsvRepositoryImpl implements ImportRegistersCsvRepository {
  @override
  Future<List<RegisterModel>> importFromCsv() async {
    // Abre o seletor de arquivo CSV
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    final file = File(result.files.single.path!);

    if (!await file.exists()) {
      throw Exception('Arquivo CSV não encontrado.');
    }

    // Lê o conteúdo e remove espaços/linhas extras
    final csvString = (await file.readAsString()).trim();

    // Faz o parsing automático de quebras de linha (\n ou \r\n)
    final csvTable = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvString);

    if (csvTable.isEmpty) {
      throw Exception('Arquivo CSV vazio.');
    }

    // Cabeçalhos
    final header = csvTable.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

       const requiredHeaders = [
      'name',
      'url',
      'username',
      'password',
      'note',
    ];

    final missingColumns = requiredHeaders
        .where((h) => !header.contains(h.toLowerCase()))
        .toList();

    if (missingColumns.isNotEmpty) {
      throw Exception(
        'O arquivo CSV não está no formato esperado. '
        'Colunas obrigatórias: ${requiredHeaders.join(', ')}.',
      );
    }

    // Linhas de dados
    final dataRows = csvTable.skip(1).where((row) => row.isNotEmpty).toList();
    if (dataRows.isEmpty) {
      throw Exception('Nenhum dado encontrado no arquivo CSV.');
    }

    // Converte cada linha em RegisterModel
    final entries = dataRows.map((row) {
      final map = <String, dynamic>{};

       if (!header.contains('id')) {
        header.insert(0, 'id');
        for (final row in dataRows) {
          row.insert(0, Uuid().v4());
        }
      }

      
      for (int i = 0; i < header.length && i < row.length; i++) {
        map[header[i]] = row[i]?.toString().trim();
      }
      return RegisterModel.fromMap(map);
    }).toList();

    // Log de verificação
    for (final e in entries) {
      log('Registro CSV importado: ${e.name}');
    }

    return entries;
  }
}

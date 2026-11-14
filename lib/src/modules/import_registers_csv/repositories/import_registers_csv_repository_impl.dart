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
    // 1. Abre o seletor de arquivo
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result?.path == null) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    final file = File(result!.path!);

    if (!await file.exists()) {
      throw Exception('Arquivo CSV não encontrado.');
    }

    // 2. Leitura com trim para remover espaços/breaks extras
    final csvString = (await file.readAsString()).trim();

    final csvTable = const CsvDecoder(fieldDelimiter: ',', dynamicTyping: false)
        .convert(csvString);

    if (csvTable.isEmpty) {
      throw Exception('Arquivo CSV vazio.');
    }

    // 3. Cabeçalhos
    final header = csvTable.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

    const requiredHeaders = ['name', 'url', 'username', 'password', 'note'];

    final missingColumns = requiredHeaders
        .where((h) => !header.contains(h))
        .toList();

    if (missingColumns.isNotEmpty) {
      throw Exception(
        'O arquivo CSV não está no formato esperado. '
        'Colunas necessárias: ${requiredHeaders.join(', ')}.',
      );
    }

    // 4. Linhas de dados (SEM linhas vazias)
    final dataRows = csvTable.skip(1).where((row) {
      // Remove linhas 100% vazias
      final hasOnlyEmpty = row.every((cell) => cell.toString().trim().isEmpty);
      return !hasOnlyEmpty;
    }).toList();

    if (dataRows.isEmpty) {
      throw Exception('Nenhum dado válido encontrado no arquivo.');
    }

    // Cada registro importado recebe um ID novo, mesmo se o CSV tiver a coluna id.
    final entries = dataRows.map((row) {
      final map = <String, dynamic>{};

      for (int i = 0; i < header.length; i++) {
        final field = header[i];
        if (field == 'id') continue;
        final value = (i < row.length) ? row[i].toString().trim() : '';
        map[field] = value;
      }

      map['id'] = const Uuid().v4();
      return RegisterModel.fromMap(map);
    }).toList();

    // Log
    log('Importação concluída — total: ${entries.length} registros');

    return entries;
  }
}

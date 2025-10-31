import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:path_provider/path_provider.dart';

class ExportRegistersCsvRepositoryImpl implements ExportRegistersCsvRepository {
  @override
  Future<File> exportToCsv(List<RegisterModel> registros) async {
    try {
      if (registros.isEmpty) {
        throw Exception('Nenhum dado disponível para exportar.');
      }

      // Cabeçalho
      const headers = ['name', 'url', 'username', 'password', 'note'];

      // Conteúdo dos registros
      final rows = registros
          .map((e) => [
                e.name,
                e.url,
                e.username,
                e.password,
                e.note,
              ])
          .toList();

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

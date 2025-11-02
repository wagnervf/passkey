import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';



class ExportRegistersCsvRepositoryImpl implements ExportRegistersCsvRepository {
  @override
  Future<File?> exportToCsv(List<RegisterModel> registros) async {
    try {
      if (registros.isEmpty) {
        throw Exception('Nenhum dado disponível para exportar.');
      }

      // Cabeçalho
      const headers = ['Nome', 'URL', 'Usuário', 'Senha', 'Observação'];

      // Linhas de dados
      final rows = registros.map((e) => [
            e.name ?? '',
            e.url ?? '',
            e.username ?? '',
            e.password ?? '',
            e.note ?? '',
          ]).toList();

      final csvData = const ListToCsvConverter().convert([headers, ...rows]);

      // Cria nome único do arquivo
      final now = DateTime.now();
      final formattedDate =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
      final fileName = 'registros_$formattedDate.csv';

      // Cria arquivo temporário
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      log('📁 Arquivo CSV gerado temporariamente: ${file.path}');

      // Compartilha diretamente com o SharePlus
      final shareParams = ShareParams(
        text: 'Aqui está o backup dos seus registros.',
        subject: 'Backup de Registros CSV',
        files: [XFile(file.path)],
      );

      final result = await SharePlus.instance.share(shareParams);

      // Se o usuário cancelar, exclui o arquivo imediatamente
      if (result.status != ShareResultStatus.success) {
        if (await file.exists()) {
          await file.delete();
          log('🗑️ Arquivo removido — o usuário cancelou o compartilhamento.');
        }
        return null;
      }

      log('✅ Registros compartilhados com sucesso!');
      return file; // retorna o arquivo só se foi realmente compartilhado
    } catch (e, s) {
      log('❌ Erro ao exportar CSV: $e', stackTrace: s);
      return null;
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

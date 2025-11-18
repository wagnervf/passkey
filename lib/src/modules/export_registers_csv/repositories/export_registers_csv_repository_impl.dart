import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportRegistersCsvRepositoryImpl implements ExportRegistersCsvRepository {
  final headers = ['name', 'url', 'username', 'password', 'note'];

  @override
  Future<File?> exportToCsv(List<RegisterModel> registros) async {
    try {
      if (registros.isEmpty) {
        throw Exception('Nenhum dado disponível para exportar.');
      }

      // Cabeçalho

      // Linhas de dados
      final rows = registros
          .map(
            (e) => [
              e.name ?? '',
              e.url ?? '',
              e.username ?? '',
              e.password ?? '',
              e.note ?? '',
            ],
          )
          .toList();

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
        subject: fileName,

        files: [XFile(file.path)],
      );

      final result = await SharePlus.instance.share(shareParams);

      // Se o usuário cancelar, exclui o arquivo imediatamente
      if (result.status != ShareResultStatus.success) {
        Future.delayed(const Duration(seconds: 3), () async {
          if (await file.exists()) await file.delete();
          log('🗑️ Arquivo removido — o usuário cancelou o compartilhamento.');
        });
        return null;
      }

      log('✅ Registros compartilhados com sucesso!');
      return file; // retorna o arquivo só se foi realmente compartilhado
    } catch (e, s) {
      log('❌ Erro ao exportar CSV: $e', stackTrace: s);
      return null;
    }
  }

  @override
  /// Cria um CSV modelo vazio (apenas cabeçalhos)
  Future<void> exportEmptyCsvTemplate() async {
    try {
      const headersExemple = ['name', 'url', 'username', 'password', 'note'];
      final csvData = const ListToCsvConverter().convert([headersExemple]);

      final now = DateTime.now();
      final formattedDate =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
      final fileName = 'modelo_registros_$formattedDate.csv';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      final params = ShareParams(
        text: 'Modelo CSV de registros para preenchimento manual.',
        subject: 'Modelo de Registros CSV',
        files: [XFile(file.path)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        log('Modelo CSV compartilhado com sucesso.');
      } else {
        log('Usuário cancelou o compartilhamento.');
      }

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e, s) {
      log('Erro ao exportar modelo CSV: $e', stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<void> exportSingleRegisterCsv(RegisterModel register) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/registro_${register.id}.csv';
      final file = File(filePath);

      // Criação do CSV com cabeçalho + uma linha
      final csvContent = _buildCsvFromRegister(register);
      await file.writeAsString(csvContent);

      final params = ShareParams(
        text: 'Compartilhando um registrpo CSV.',
        files: [XFile(file.path)],
      );

      await SharePlus.instance.share(params);

      // Remove o arquivo após o compartilhamento
      await file.delete();
    } catch (e) {
      rethrow;
    }
  }

  String _buildCsvFromRegister(RegisterModel register) {
    // Cabeçalho
    const header = 'name,url,username,password,note\n';

    // Trata valores nulos e caracteres problemáticos (como vírgula ou quebra de linha)
    String sanitize(String? value) {
      if (value == null || value.isEmpty) return '';
      final clean = value.replaceAll('\n', ' ').replaceAll(',', ';');
      return '"$clean"'; // garante que campos com espaços sejam bem interpretados
    }

    // Linha única do registro
    final line =
        '${[sanitize(register.name), sanitize(register.url), sanitize(register.username), sanitize(register.password), sanitize(register.note)].join(',')}\n';

    return header + line;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

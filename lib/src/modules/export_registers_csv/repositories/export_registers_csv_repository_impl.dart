import 'dart:developer';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportRegistersCsvRepositoryImpl implements ExportRegistersCsvRepository {
  static const _exportFolder = 'keezy_exports';
  static final _sharedCsvName = RegExp(
    r'^(registros_|registro_|modelo_registros_).+\.csv$',
  );

  ExportRegistersCsvRepositoryImpl({
    Future<Directory> Function()? temporaryDirectory,
    Future<ShareResult> Function(ShareParams)? share,
  })  : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
        _share = share ?? SharePlus.instance.share;

  final Future<Directory> Function() _temporaryDirectory;
  final Future<ShareResult> Function(ShareParams) _share;
  final headers = ['name', 'url', 'username', 'password', 'note'];

  /// Clears copies left by a process interruption. Android's share_plus also
  /// makes its own cache copy; it is safe to remove on the next app launch.
  static Future<void> cleanupStaleExports({Directory? temporaryDirectory}) async {
    try {
      final temp = temporaryDirectory ?? await getTemporaryDirectory();
      final exports = Directory('${temp.path}/$_exportFolder');
      if (await exports.exists()) await exports.delete(recursive: true);

      if (Platform.isAndroid || Platform.isIOS) {
        // Older versions wrote exports directly to the app's temp directory.
        await for (final entity in temp.list(followLinks: false)) {
          if (entity is File &&
              _sharedCsvName.hasMatch(entity.uri.pathSegments.last)) {
            await entity.delete();
          }
        }
      }

      if (Platform.isAndroid) {
        final shared = Directory('${temp.path}/share_plus');
        if (await shared.exists()) {
          await for (final entity in shared.list(followLinks: false)) {
            if (entity is File &&
                _sharedCsvName.hasMatch(entity.uri.pathSegments.last)) {
              await entity.delete();
            }
          }
        }
      }
    } catch (_) {
      log('Não foi possível limpar arquivos CSV temporários antigos.');
    }
  }

  Future<Directory> _createExportDirectory() async {
    final temp = await _temporaryDirectory();
    return Directory('${temp.path}/$_exportFolder').create(recursive: true);
  }

  @override
  Future<bool> exportToCsv(List<RegisterModel> registros) async {
    File? file;
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

      final csvData = const CsvEncoder().convert([headers, ...rows]);

      // Cria nome único do arquivo
      final now = DateTime.now();
      final formattedDate =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
      final fileName =
          'registros_${formattedDate}_${now.microsecondsSinceEpoch}.csv';

      // Cria arquivo temporário
      final dir = await _createExportDirectory();
      file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      log('Arquivo CSV temporário gerado.');

      // Compartilha diretamente com o SharePlus
      final shareParams = ShareParams(
        text: 'Aqui está o backup dos seus registros.',
        subject: fileName,

        files: [XFile(file.path)],
      );

      final result = await _share(shareParams);
      return result.status == ShareResultStatus.success;
    } catch (_) {
      log('Erro ao exportar CSV.');
      rethrow;
    } finally {
      await _deleteTemporaryFile(file);
    }
  }

  @override
  /// Cria um CSV modelo vazio (apenas cabeçalhos)
  Future<void> exportEmptyCsvTemplate() async {
    File? file;
    try {
      const headersExemple = ['name', 'url', 'username', 'password', 'note'];
      final csvData = const CsvEncoder().convert([headersExemple]);

      final now = DateTime.now();
      final formattedDate =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_'
          '${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
      final fileName =
          'modelo_registros_${formattedDate}_${now.microsecondsSinceEpoch}.csv';

      final dir = await _createExportDirectory();
      file = File('${dir.path}/$fileName');
      await file.writeAsString(csvData);

      final params = ShareParams(
        text: 'Modelo CSV de registros para preenchimento manual.',
        subject: 'Modelo de Registros CSV',
        files: [XFile(file.path)],
      );

      final result = await _share(params);

      if (result.status != ShareResultStatus.success) {
        throw StateError('Compartilhamento não confirmado.');
      }
      log('Modelo CSV compartilhado com sucesso.');

    } catch (_) {
      log('Erro ao exportar modelo CSV.');
      rethrow;
    } finally {
      await _deleteTemporaryFile(file);
    }
  }

  @override
  Future<void> exportSingleRegisterCsv(RegisterModel register) async {
    File? file;
    try {
      final directory = await _createExportDirectory();
      final filePath =
          '${directory.path}/registro_${DateTime.now().microsecondsSinceEpoch}.csv';
      file = File(filePath);

      // Criação do CSV com cabeçalho + uma linha
      final csvContent = _buildCsvFromRegister(register);
      await file.writeAsString(csvContent);

      final params = ShareParams(
        text: 'Compartilhando um registro CSV.',
        files: [XFile(file.path)],
      );

      final result = await _share(params);
      if (result.status != ShareResultStatus.success) {
        throw StateError('Compartilhamento não confirmado.');
      }
    } finally {
      await _deleteTemporaryFile(file);
    }
  }

  Future<void> _deleteTemporaryFile(File? file) async {
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  String _buildCsvFromRegister(RegisterModel register) {
    return const CsvEncoder().convert([
      headers,
      [
        register.name ?? '',
        register.url ?? '',
        register.username ?? '',
        register.password ?? '',
        register.note ?? '',
      ],
    ]);
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

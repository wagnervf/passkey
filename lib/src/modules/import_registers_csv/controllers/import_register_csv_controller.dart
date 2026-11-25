import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/csv_import_preview.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository.dart';
import 'package:keezy/src/modules/import_registers_csv/services/import_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';

class ImportRegisterCsvController extends Cubit<ImportRegistersCsvState> {
  ImportRegisterCsvController({
    required this.importRegistersCsvServices,
    required this.registerController,
  }) : super(ImportCsvInitial());

  final ImportRegistersCsvServices importRegistersCsvServices;
  final RegisterController registerController;
  bool _busy = false;

  Future<CsvImportPreview?> prepareImport() async {
    if (_busy) return null;
    _busy = true;
    emit(ImportCsvLoading());
    try {
      final imported = await importRegistersCsvServices.importFromCsv();
      if (imported.isEmpty) {
        emit(ImportCsvNull('Nenhum registro encontrado no arquivo.'));
        return null;
      }
      final current = await registerController.getRegisterForExportCsv();
      if (current == null) {
        emit(ImportCsvError('Não foi possível ler o cofre. Tente novamente.'));
        return null;
      }
      final preview = CsvImportPreview.create(
        imported: imported,
        current: current,
      );
      emit(ImportCsvInitial());
      return preview;
    } on CsvImportCancelled {
      emit(ImportCsvInitial());
      return null;
    } catch (_) {
      log('Erro ao preparar importação CSV.');
      emit(ImportCsvError('Erro ao ler CSV. Verifique o arquivo.'));
      return null;
    } finally {
      _busy = false;
    }
  }

  Future<bool> commitImport(CsvImportPreview preview) async {
    if (_busy) return false;
    _busy = true;
    emit(ImportCsvLoading());
    try {
      final current = await registerController.getRegisterForExportCsv();
      if (current == null) {
        emit(ImportCsvError('Não foi possível ler o cofre. Tente novamente.'));
        return false;
      }
      if (!preview.matchesVault(current)) {
        emit(
          ImportCsvError(
            'O cofre mudou desde a prévia. Selecione o CSV novamente.',
          ),
        );
        return false;
      }
      if (preview.newCount == 0) {
        emit(ImportCsvInitial());
        return false;
      }

      final saved = await registerController.addNewRegistersController(
        preview.toImport,
      );
      if (!saved) {
        emit(
          ImportCsvError(
            'Importação interrompida. Registros anteriores foram mantidos. '
            'Selecione o mesmo CSV para concluir.',
          ),
        );
        return false;
      }

      final verified = await registerController.getRegisterForExportCsv();
      final byId = {for (final record in verified ?? []) record.id: record};
      final complete =
          verified != null &&
          preview.toImport.every((expected) {
            final actual = byId[expected.id];
            return actual != null &&
                CsvImportPreview.hasSameContent(actual, expected);
          });
      if (!complete) {
        emit(
          ImportCsvError(
            'Não foi possível confirmar todos os registros. '
            'Selecione o mesmo CSV para concluir.',
          ),
        );
        return false;
      }

      emit(
        ImportCsvLoaded(
          '${preview.newCount} registro(s) importado(s); '
          '${preview.duplicates} duplicado(s) ignorado(s).',
        ),
      );
      return true;
    } catch (_) {
      log('Erro ao salvar importação CSV.');
      emit(
        ImportCsvError(
          'Importação interrompida. Registros anteriores foram mantidos. '
          'Selecione o mesmo CSV para concluir.',
        ),
      );
      return false;
    } finally {
      _busy = false;
    }
  }
}

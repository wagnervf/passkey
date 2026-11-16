import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:keezy/src/modules/import_registers_csv/services/import_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:uuid/uuid.dart';

class ImportRegisterCsvController extends Cubit<ImportRegistersCsvState> {
  final ImportRegistersCsvServices importRegistersCsvServices;
  final RegisterController registerController;

  ImportRegisterCsvController({
    required this.importRegistersCsvServices,
    required this.registerController,
  }) : super(ImportCsvInitial());

  Future<List<RegisterModel>?> importFromCsv() async {
    emit(ImportCsvLoading());

    try {
      final registers = await importRegistersCsvServices.importFromCsv();

      if (registers.isEmpty) {
        const msg = 'Nenhum registro válido encontrado no arquivo!';
        emit(ImportCsvNull(msg));
        return null;
      }

      log('Registros importados: ${registers.length}');
      emit(ImportCsvLoaded('Registros importados: ${registers.length}'));

      return registers;
    } catch (_) {
      log('Erro ao importar CSV.');
      emit(ImportCsvError('Erro ao importar CSV. Verifique o arquivo.'));
      return null;
    }
  }
  
  Future<String?> restoreBackupFromFileCsv() async {
    emit(ImportCsvLoading());
    try {
      // 1. Importa do CSV
      final importedRegisters = await importFromCsv();

      if (importedRegisters == null || importedRegisters.isEmpty) {
        const msg = 'Nenhum registro encontrado!';
        emit(ImportCsvNull(msg));
        return msg;
      }

      // 2. Busca registros já existentes
      final currentRegisters =
          await registerController.getRegisterForExportCsv() ?? [];

      // 3. Garante ID ÚNICO para cada importado
      final newRegisters = importedRegisters
          .map((r) => r.copyWith(id: const Uuid().v4()))
          .toList();

      // 4. Junta tudo numa só lista
      final allRegisters = [...currentRegisters, ...newRegisters];

      // 5. Salva tudo de uma vez (mais seguro e rápido)
      final success = await registerController.saveListRegistersController(
        allRegisters,
      );

      if (!success) {
        emit(ImportCsvError('Erro ao salvar registros!'));
        return 'Erro ao salvar registros!';
      }

      emit(ImportCsvLoaded('Importação concluída com sucesso!'));
      return 'Importação concluída com sucesso!';
    } catch (_) {
      log('Erro ao restaurar registros do CSV.');
      const errorMsg = 'Erro ao restaurar registros do CSV.';
      emit(ImportCsvError(errorMsg));
      return errorMsg;
    }
  }
}

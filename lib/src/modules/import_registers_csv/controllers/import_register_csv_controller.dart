import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:keezy/src/modules/import_registers_csv/services/import_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class ImportRegisterCsvController extends Cubit<ImportRegistersCsvState> {
  final ImportRegistersCsvServices importRegistersCsvServices;
  final RegisterController registerController;

  ImportRegisterCsvController({
    required this.importRegistersCsvServices,
    required this.registerController,
  }) : super(ImportCsvInitial());

  importFromCsv() async {
    emit(ImportCsvLoading());
    try {
      final registers = await importRegistersCsvServices.importFromCsv();

      log(registers.toString());

      emit(ImportCsvLoaded());
      return registers;
    } catch (e) {
      emit(ImportCsvError(e.toString()));
    }
  }

  Future<String?> restoreBackupFromFileCsv() async {
    try {
      emit(ImportCsvLoading());
      // name	url	username	password	note

      final resultado = await importFromCsv();

      if (resultado != null) {
        List<RegisterModel> registros = resultado;

        log('Registros importados: ${registros.length}');

        // Salvar usuário corretamente via AuthController
        await registerController.saveListRegisterController(registros);

        emit(ImportCsvLoaded());

        return 'Usuário importado!';
      } else {
        log('Falha ao importar os dados.');
        emit(ImportCsvError('Falha ao importar os dados.'));
        return 'Falha ao importar os dados.';
      }
    } catch (e) {
      emit(ImportCsvError("Erro ao importar backup: $e"));
      return "Erro ao importar backup: $e";
    }
  }
}

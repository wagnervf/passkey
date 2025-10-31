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

  Future<List<RegisterModel>?> importFromCsv() async {
    emit(ImportCsvLoading());
    try {
      final registers = await importRegistersCsvServices.importFromCsv();

        if (registers.isEmpty) {
        const msg = 'Nenhum registro selecionado!';
        emit(ImportCsvNull(msg));
        return null;
     }

      log('Registros importados: ${registers.length}');
      emit(ImportCsvLoaded('Registros importados: ${registers.length}'));
      return registers;
    } catch (e) {
     // final errorMsg = 'Erro ao importar CSV: $e';
      log(e.toString());
      emit(ImportCsvError(e.toString()));
      return null;
    }
  }

  Future<String?> restoreBackupFromFileCsv() async {
    emit(ImportCsvLoading());

    try {
      final List<RegisterModel>? registers = await importFromCsv();

      if (registers == null || registers.isEmpty) {
        const msg = 'Nenhum registro encontrado!';
        emit(ImportCsvNull(msg));
        return msg;
      }

      for (final register in registers) {
        log('Salvando registro: ${register.name}');
        await registerController.saveAndUpdateRegisterController(register);
      }

      emit(ImportCsvLoaded('Dados importados com sucesso!'));
      return 'Dados importados com sucesso!';
    } catch (e) {
      final errorMsg = 'Erro ao importar backup: $e';
      emit(ImportCsvError(errorMsg));
      return errorMsg;
    }
  }



 
}


import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_registers_csv_state.dart';
import 'package:keezy/src/modules/export_registers_csv/services/export_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class ExportRegisterCsvController extends Cubit<ExportRegistersCsvState> {
  final ExportRegistersCsvServices exportRegistersCsvServices;
  final RegisterController registerController;

  ExportRegisterCsvController({
    required this.exportRegistersCsvServices,
    required this.registerController,
  }) : super(ExportCsvInitial());

  Future<bool> hasRegisters() async {
    final registros = await registerController.getRegisterForExportCsv();
    return registros?.isNotEmpty ?? false;
  }

  Future<bool> exportFileCsv() async {
    emit(ExportCsvLoading());

    try {
      final List<RegisterModel>? registros = await registerController
          .getRegisterForExportCsv();

      if (registros == null || registros.isEmpty) {
        const msg = 'Nenhum registro para ser exportado!';
        emit(ExportCsvNull(msg));
        return false;
      }

      log('Exportando ${registros.length} registros...');

      final shared = await exportRegistersCsvServices
          .exportRegistersCsvServices(registros);

      if (!shared) {
        emit(ExportCsvNull('Compartilhamento cancelado ou não confirmado.'));
        return false;
      }
      emit(ExportCsvLoaded('Registros compartilhados com sucesso.'));
      return true;
    } catch (_) {
      log('Erro ao exportar CSV.');
      emit(ExportCsvError('Erro ao exportar CSV.'));
      return false;
    }
  }

  Future<void> exportSingleRegister(RegisterModel register) async {
    try {
      emit(ExportCsvLoading());
      await exportRegistersCsvServices.exportSingleRegisterCsv(register);
      emit(ExportCsvLoaded('Registro exportado com sucesso!'));
    } catch (_) {
      emit(ExportCsvError('Erro ao exportar o registro.'));
    }
  }

  Future<void> exportEmptyTemplate() async {
    emit(ExportCsvLoading());
    try {
      await exportRegistersCsvServices.exportEmptyCsvTemplate();
      emit(ExportCsvLoaded('Modelo CSV compartilhado com sucesso.'));
    } catch (_) {
      emit(ExportCsvError('Erro ao gerar modelo CSV.'));
    }
  }
}

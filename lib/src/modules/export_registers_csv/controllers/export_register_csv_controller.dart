import 'dart:developer';
import 'dart:io';

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

 Future<File?> exportFileCsv() async {
  emit(ExportCsvLoading());

  try {
    final List<RegisterModel>? registros = await registerController.getRegisterForExportCsv();

    if (registros == null || registros.isEmpty) {
      const msg = 'Nenhum registro para ser exportado!';
      emit(ExportCsvNull(msg));
      return null;
    }

    log('Exportando ${registros.length} registros...');

    final File file = await exportRegistersCsvServices.exportRegistersCsvServices(registros);

    emit(ExportCsvLoaded('Registros exportados para: ${file.path}'));

    return file;
  } catch (e) {
    log('Erro ao exportar CSV: $e');
    emit(ExportCsvError('Erro ao exportar CSV: $e'));
    return null;
  }
}




 
}


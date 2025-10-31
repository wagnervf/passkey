import 'dart:io';

import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository.dart';
import 'package:keezy/src/modules/export_registers_csv/services/export_registers_csv_services.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class ExportRegistersCsvServicesImpl implements ExportRegistersCsvServices {
  final ExportRegistersCsvRepository repository;

  ExportRegistersCsvServicesImpl({required this.repository});

  @override
  Future<File> exportRegistersCsvServices(List<RegisterModel> registros) {
    return repository.exportToCsv(registros);
  }
}

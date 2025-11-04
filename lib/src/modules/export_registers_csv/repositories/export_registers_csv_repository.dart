import 'dart:io';

import 'package:keezy/src/modules/register/model/register_model.dart';

abstract interface class ExportRegistersCsvRepository {

  Future<File?> exportToCsv(List<RegisterModel> registros);
  
  Future<void> exportSingleRegisterCsv(RegisterModel register);


  Future<void> exportEmptyCsvTemplate();
}

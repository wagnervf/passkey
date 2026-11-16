import 'package:keezy/src/modules/register/model/register_model.dart';

abstract interface class ExportRegistersCsvRepository {

  Future<bool> exportToCsv(List<RegisterModel> registros);
  
  Future<void> exportSingleRegisterCsv(RegisterModel register);


  Future<void> exportEmptyCsvTemplate();
}

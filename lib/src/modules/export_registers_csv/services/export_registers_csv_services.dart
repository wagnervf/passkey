
import 'package:keezy/src/modules/register/model/register_model.dart';

abstract class ExportRegistersCsvServices {
  Future<bool> exportRegistersCsvServices(List<RegisterModel> registers);
  
  Future exportSingleRegisterCsv(RegisterModel register);

  Future<void> exportEmptyCsvTemplate();

}

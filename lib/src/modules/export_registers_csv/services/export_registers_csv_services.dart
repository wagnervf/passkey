
import 'package:keezy/src/modules/register/model/register_model.dart';

abstract class ExportRegistersCsvServices {
  Future exportRegistersCsvServices(List<RegisterModel> registers);

}
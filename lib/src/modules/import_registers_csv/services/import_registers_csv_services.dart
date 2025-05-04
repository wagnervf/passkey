
import 'package:keezy/src/modules/register/model/registro_model.dart';

abstract class ImportRegistersCsvServices {
  Future<List<RegisterModel>> importFromCsv();
  

}
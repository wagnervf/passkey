
import 'package:keezy/src/modules/register/model/register_model.dart';

abstract class ImportRegistersCsvServices {
  Future<List<RegisterModel>> importFromCsv();

}
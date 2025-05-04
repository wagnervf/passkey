
import 'dart:io';

import 'package:keezy/src/modules/register/model/registro_model.dart';

abstract interface class ImportRegistersCsvRepository {
  Future<List<RegisterModel>> importFromCsv(File file);

}
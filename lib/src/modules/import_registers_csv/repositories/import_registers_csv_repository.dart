
import 'dart:io';

import 'package:keezy/src/modules/register/model/register_model.dart';

abstract interface class ImportRegistersCsvRepository {
  Future<List<RegisterModel>> importFromCsv(File file);

}
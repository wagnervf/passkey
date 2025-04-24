import 'dart:io';

import 'package:passkey/src/modules/register/model/registro_model.dart';

abstract class ImportRegistersCsvServices {
  Future<List<RegisterModel>> importFromCsv();
  

}
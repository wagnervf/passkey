import 'package:keezy/src/modules/register/model/register_model.dart';

abstract interface class ImportRegistersCsvRepository {
  Future<List<RegisterModel>> importFromCsv();
}

class CsvImportCancelled implements Exception {
  const CsvImportCancelled();
}


import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository.dart';
import 'package:keezy/src/modules/import_registers_csv/services/import_registers_csv_services.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

class ImportRegistersCsvServicesImpl implements ImportRegistersCsvServices {
  final ImportRegistersCsvRepository repository;

  ImportRegistersCsvServicesImpl({required this.repository});

  @override
  Future<List<RegisterModel>> importFromCsv() async {
   
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      if (result.files.single.extension == 'csv') {
        final file = File(result.files.single.path!);
        return await repository.importFromCsv(file);
      } else {
        throw Exception('Arquivo selecionado não é um CSV válido');
      }
    } else {
      throw Exception('Nenhum arquivo selecionado');
    }
  }
   }


import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveConfig {
  static Future<void> start() async {
    // Diretório onde os boxes ficam armazenados
    Directory dir = await getApplicationDocumentsDirectory();

    // Inicializa Hive
    await Hive.initFlutter(dir.path);
  }
}

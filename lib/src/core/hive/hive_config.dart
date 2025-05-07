
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:path_provider/path_provider.dart';

class HiveConfig {
  static Future<void> start() async {

    Directory dir = await getApplicationDocumentsDirectory();
    // Initialize Hive
    await Hive.initFlutter(dir.path);

    // Register your adapters here
    await RegisterHive.init();


    
   
  }
}
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:keezy/src/app_widget.dart';
import 'package:keezy/src/application_binding.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/hive/hive_config.dart';
import 'package:keezy/src/core/shared_preferences/shared_preferences_service.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await HiveConfig.start();
      await SharedPreferencesService.init();
      SecureStorageService.init();
     
    
      runApp(
         ApplicationBinding(
          child: AppWidget(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      log('Erro não tratado!', error: error, stackTrace: stack);
    },
  );
}


//https://www.youtube.com/watch?v=a8MNW97GuiI&t=1037s&ab_channel=Prof.DiegoAntunes
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keezy/src/app_widget.dart';
import 'package:keezy/src/application_binding.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/shared_preferences/shared_preferences_service.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SharedPreferencesService.init();
      SecureStorageService.init();
     
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor:
              Colors.transparent, // Deixa o fundo da status bar transparente
          statusBarIconBrightness:
              Brightness.dark, // Ícones escuros (relógio, Wi-Fi etc)
          statusBarBrightness: Brightness.light, // Para iOS (se precisar)
        ),
      );

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


//https://www.youtube.com/watch?v=zImUYcq-q30&ab_channel=J%C3%A1codouhoje%3F

//34:54
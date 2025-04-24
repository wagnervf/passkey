import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:passkey/src/app_widget.dart';
import 'package:passkey/src/application_binding.dart';
import 'package:passkey/src/core/data/services/secure_storage_service.dart';
import 'package:passkey/src/core/shared_preferences/shared_preferences_service.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SharedPreferencesService.init();
      SecureStorageService.init();

      runApp(
        const ApplicationBinding(
          child: AppWidget(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      log('Erro não tratado!', error: error, stackTrace: stack);
    },
  );
}

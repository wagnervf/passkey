import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:keezy/src/app_widget.dart';
import 'package:keezy/src/application_binding.dart';
import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/hive/hive_config.dart';
import 'package:keezy/src/core/session/session_manager.dart';
import 'package:keezy/src/core/shared_preferences/shared_preferences_service.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository_impl.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await HiveConfig.start();
      await ExportRegistersCsvRepositoryImpl.cleanupStaleExports();
      RegisterHive.init();
      await SharedPreferencesService.init();
      SecureStorageService.init();

      runApp(ApplicationBinding(child: AppWidget()));
    },
    (Object error, StackTrace stack) {
      log('Erro não tratado.');
    },
  );
}

// Tempo de Sessão
class ActivityObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) =>
      SessionManager.updateActivity();
  @override
  void didPush(Route route, Route? previousRoute) =>
      SessionManager.updateActivity();
}

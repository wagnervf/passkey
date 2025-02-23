import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passkey/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:passkey/src/core/shared_preferences/shared_preferences_service.dart';
import 'package:passkey/src/core/storage/i_token_storage.dart';
import 'package:passkey/src/core/storage/token_storage.dart';
import 'package:passkey/src/core/theme/controller/theme_controller.dart';
import 'package:passkey/src/core/theme/services/theme_service.dart';
import 'package:passkey/src/core/theme/services/theme_service_impl.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/auth/repositories/auth_repository.dart';
import 'package:passkey/src/modules/configuracoes/controllers/configuracoes_controller.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/repositories/register_repository.dart';
import 'package:passkey/src/modules/register/repositories/register_repository_impl.dart';

import 'package:provider/provider.dart';

class ApplicationBinding extends StatelessWidget {
  const ApplicationBinding({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sharedPreferences = SharedPreferencesService().sharedPreferences;
    return MultiProvider(
      providers: [
        // Provider<RestClient>(create: (context) => RestClient()),
        Provider<TokenStorageInterface>(
          lazy: true,
          create: (context) => TokenStorage(),
        ),
        Provider<ThemeService>(
          lazy: true,
          create: (context) => ThemeServiceImpl(),
        ),
        ChangeNotifierProvider(
          lazy: true,
          create: ((context) => ThemeController(themeService: context.read())),
        ),

        //Provider<GoogleAuthServices>(lazy: true, create: (context) => AuthServices()),
        Provider<AuthRepository>(
            lazy: true, create: (context) => AuthRepository()),
        Provider<AuthController>(
            lazy: true,
            create: (context) => AuthController(
                  authRepository: context.read(),
                  tokenStorage: context.read(),
                )),
        Provider<Cubit<AuthState>>(
            lazy: true,
            create: (context) => AuthController(
                  tokenStorage: context.read(),
                  authRepository: context.read(),
                )),

        ChangeNotifierProvider<ConfiguracoesController>(
          lazy: true,
          create: (context) => ConfiguracoesController(
            sharedPreferences: sharedPreferences,
          ),
        ),

        Provider<RegisterRepository>(
            lazy: true, create: (context) => RegisterRepositoryImpl()),

        Provider<RegisterController>(
            lazy: true,
            create: (context) =>
                RegisterController(registerRepository: context.read())),

        Provider<BackupRestoreController>(
            lazy: true, create: (context) => BackupRestoreController(registerControllerX: context.read() )),

            
      ],
      child: child,
    );
  }
}

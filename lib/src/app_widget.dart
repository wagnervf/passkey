import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/theme/controller/theme_controller.dart';
import 'package:passkey/src/core/theme/core_theme.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeController>();
    return MaterialApp.router(
        title: 'Passkey',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeConfig.isDark ? ThemeMode.dark : ThemeMode.system,
        debugShowCheckedModeBanner: false,
        routerConfig: routes,
        
    );
  }
}

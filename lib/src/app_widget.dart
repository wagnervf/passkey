import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/theme/controller/theme_controller.dart';
import 'package:keezy/src/core/theme/core_theme.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  AppWidgetState createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget> {
  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeController>();
    return MaterialApp.router(
      title: 'keezy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeConfig.isDark ? ThemeMode.dark : ThemeMode.system,
      debugShowCheckedModeBanner: false,
      routerConfig: routes,
    );
  }
}
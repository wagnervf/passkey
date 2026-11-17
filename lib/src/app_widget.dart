import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/session/session_manager.dart';
import 'package:keezy/src/core/theme/controller/theme_controller.dart';
import 'package:keezy/src/core/theme/core_theme.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  AppWidgetState createState() => AppWidgetState();
}

class AppWidgetState extends State<AppWidget> with WidgetsBindingObserver {
  Future<void>? _lockInProgress;
  bool _covered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SessionManager.configure(onExpired: _lockVault);
  }

  Future<void> _lockVault() {
    if (_lockInProgress != null) return _lockInProgress!;
    if (mounted) setState(() => _covered = true);
    final future = context.read<AuthController>().lockVault().whenComplete(() {
      if (mounted) routes.go(RoutesPaths.digitarSenha);
    });
    _lockInProgress = future.whenComplete(() => _lockInProgress = null);
    return _lockInProgress!;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      SessionManager.background();
    } else if (state == AppLifecycleState.inactive) {
      if (mounted) setState(() => _covered = true);
    } else if (state == AppLifecycleState.resumed) {
      SessionManager.setForeground(true);
      final pending = _lockInProgress;
      if (pending != null) {
        pending.whenComplete(() {
          if (mounted) setState(() => _covered = false);
        });
      } else if (_covered) {
        setState(() => _covered = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = context.watch<ThemeController>();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => SessionManager.updateActivity(),
      child: Stack(
        children: [
          MaterialApp.router(
            title: 'keezy',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeConfig.isDark ? ThemeMode.dark : ThemeMode.system,
            debugShowCheckedModeBanner: false,
            routerConfig: routes,
          ),
          if (_covered)
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
        ],
      ),
    );
  }
}

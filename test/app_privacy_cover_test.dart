import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/app_widget.dart';
import 'package:keezy/src/core/session/session_manager.dart';
import 'package:keezy/src/core/theme/controller/theme_controller.dart';
import 'package:keezy/src/core/theme/services/theme_service.dart';
import 'package:keezy/src/modules/welcome/master_password_creation_screen.dart';
import 'package:provider/provider.dart';

class _ThemeService implements ThemeService {
  @override
  Future<bool> getTheme() async => false;

  @override
  Future<void> saveTheme(bool theme) async {}
}

void main() {
  testWidgets('seletor de backup preserva Configurações ao voltar ao app', (
    tester,
  ) async {
    SessionManager.stop();
    SessionManager.setForeground(true);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Configurações')),
        ),
      ],
    );
    final themeController = ThemeController(themeService: _ThemeService());
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeController>.value(
        value: themeController,
        child: AppWidget(router: router),
      ),
    );
    await tester.pump();

    SessionManager.start();
    SessionManager.beginSystemPicker();
    final appState = tester.state<AppWidgetState>(find.byType(AppWidget));
    appState.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump();
    expect(find.byKey(const ValueKey('privacy-cover')), findsOneWidget);
    expect(SessionManager.isActive, true);

    appState.didChangeAppLifecycleState(AppLifecycleState.resumed);
    SessionManager.endSystemPicker();
    await tester.pump();
    expect(find.byKey(const ValueKey('privacy-cover')), findsNothing);
    expect(find.text('Configurações'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    themeController.dispose();
    router.dispose();
    SessionManager.setForeground(true);
  });

  testWidgets(
    'autofill inactivity keeps the form visible; background covers it',
    (tester) async {
      SessionManager.stop();
      SessionManager.setForeground(true);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const MasterPasswordCreationScreen(),
          ),
        ],
      );
      final themeController = ThemeController(themeService: _ThemeService());

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeController>.value(
          value: themeController,
          child: AppWidget(router: router),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('master-password')));
      await tester.pump();

      final appState = tester.state<AppWidgetState>(find.byType(AppWidget));
      appState.didChangeAppLifecycleState(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.byKey(const ValueKey('privacy-cover')), findsNothing);
      expect(find.text('Crie sua senha mestra'), findsOneWidget);

      appState.didChangeAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      expect(find.byKey(const ValueKey('privacy-cover')), findsOneWidget);

      appState.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byKey(const ValueKey('privacy-cover')), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      themeController.dispose();
      router.dispose();
      SessionManager.setForeground(true);
    },
  );
}

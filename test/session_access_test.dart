import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/session/session_manager.dart';

void main() {
  tearDown(() {
    SessionManager.dispose();
    SessionManager.setForeground(true);
  });

  test('direct vault routes require an open vault and an authenticated session', () {
    const protectedPaths = [
      RoutesPaths.home,
      RoutesPaths.config,
      RoutesPaths.exportRegistersCsv,
      RoutesPaths.profile,
      RoutesPaths.register,
      RoutesPaths.listRegisters,
      RoutesPaths.importOneRegister,
      RoutesPaths.authRegister,
      RoutesPaths.masterPasswordWarning,
      RoutesPaths.biometricSetup,
      RoutesPaths.finalization,
      RoutesPaths.authValidade,
    ];

    for (final path in protectedPaths) {
      expect(
        vaultRedirect(
          path,
          vaultUnlocked: true,
          sessionActive: false,
          authenticated: true,
        ),
        RoutesPaths.digitarSenha,
        reason: path,
      );
      expect(
        vaultRedirect(
          path,
          vaultUnlocked: true,
          sessionActive: true,
          authenticated: false,
        ),
        RoutesPaths.digitarSenha,
        reason: path,
      );
      expect(
        vaultRedirect(
          path,
          vaultUnlocked: false,
          sessionActive: true,
          authenticated: true,
        ),
        RoutesPaths.digitarSenha,
        reason: path,
      );
      expect(
        vaultRedirect(
          path,
          vaultUnlocked: true,
          sessionActive: true,
          authenticated: true,
        ),
        isNull,
        reason: path,
      );
    }
  });

  testWidgets('activity renews the idle timer and expiry locks once', (tester) async {
    var locks = 0;
    SessionManager.configure(onExpired: () async => locks++);
    SessionManager.start();

    await tester.pump(const Duration(minutes: 4));
    SessionManager.updateActivity();
    await tester.pump(const Duration(minutes: 2));
    expect(locks, 0);
    await tester.pump(const Duration(minutes: 3));
    expect(locks, 1);
    expect(SessionManager.isActive, false);
    await SessionManager.expire();
    expect(locks, 1);
  });

  test('a backgrounded app cannot start a new session', () {
    SessionManager.setForeground(false);
    SessionManager.start();
    expect(SessionManager.isActive, false);
    SessionManager.setForeground(true);
    SessionManager.start();
    expect(SessionManager.isActive, true);
  });

  test('backgrounding an active session locks it once', () async {
    var locks = 0;
    SessionManager.configure(onExpired: () async => locks++);
    SessionManager.start();

    await SessionManager.background();
    expect(locks, 1);
    expect(SessionManager.isActive, false);
    expect(SessionManager.isForeground, false);
    await SessionManager.background();
    expect(locks, 1);
  });
}

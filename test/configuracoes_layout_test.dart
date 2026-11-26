import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/storage/i_token_storage.dart';
import 'package:keezy/src/core/theme/controller/theme_controller.dart';
import 'package:keezy/src/core/theme/services/theme_service.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:keezy/src/modules/configuracoes/views/pages/configuracoes_page.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/export_registers_csv/services/export_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/repositories/register_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Tokens implements TokenStorageInterface {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AuthController extends AuthController {
  _AuthController()
    : super(tokenStorage: _Tokens(), authRepository: AuthRepository()) {
    emit(AuthSuccessState(AuthUserModel(name: 'Ana')));
  }
}

class _ThemeService implements ThemeService {
  @override
  Future<bool> getTheme() async => false;
  @override
  Future<void> saveTheme(bool theme) async {}
}

class _ExportServices implements ExportRegistersCsvServices {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExportController extends ExportRegisterCsvController {
  _ExportController()
    : super(
        exportRegistersCsvServices: _ExportServices(),
        registerController: RegisterController(
          registerRepository: RegisterRepositoryImpl(),
        ),
      );

  @override
  Future<bool> hasRegisters() async => false;
}

void main() {
  testWidgets('settings cards share widths and titles; delete stays separate', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'biometric_enabled': false});
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = _AuthController();
    final export = _ExportController();
    final theme = ThemeController(themeService: _ThemeService());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthController>.value(value: auth),
          Provider<ExportRegisterCsvController>.value(value: export),
          ChangeNotifierProvider<ThemeController>.value(value: theme),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const ConfiguracoesPage(),
        ),
      ),
    );
    await tester.pump();

    final manage = find.byKey(const ValueKey('manage-records-card'));
    final backup = find.byKey(const ValueKey('backup-card'));
    final delete = find.byKey(const ValueKey('delete-all-data-card'));
    expect(tester.getSize(manage).width, tester.getSize(backup).width);
    expect(tester.getTopLeft(manage).dx, tester.getTopLeft(backup).dx);
    expect(
      find.descendant(of: backup, matching: find.byType(ListTile)),
      findsNWidgets(2),
    );
    expect(find.text('Restaurar backup Keezy'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Exportar Registros')).style?.fontSize,
      tester.widget<Text>(find.text('Criar backup Keezy')).style?.fontSize,
    );
    expect(
      tester.getTopLeft(delete).dy - tester.getBottomLeft(backup).dy,
      greaterThanOrEqualTo(72),
    );
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pumpAndSettle();
    expect(find.text('Excluir todos os dados'), findsNWidgets(2));
    expect(
      find.textContaining('backup Keezy protegido (.keezy)'),
      findsOneWidget,
    );
    expect(find.textContaining('O CSV contém senhas legíveis'), findsOneWidget);
    expect(
      find.textContaining('Guardei um backup Keezy protegido'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await auth.close();
    await export.registerController.close();
    await export.close();
    theme.dispose();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/theme/core_theme.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/export_registers_csv/services/export_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/repositories/register_repository_impl.dart';
import 'package:keezy/src/modules/register/views/pages/register_form_page.dart';
import 'package:provider/provider.dart';

class _ExportServices implements ExportRegistersCsvServices {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'formulário mantém campos acessíveis com fonte e teclado ampliados',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      final export = ExportRegisterCsvController(
        exportRegistersCsvServices: _ExportServices(),
        registerController: RegisterController(
          registerRepository: RegisterRepositoryImpl(),
        ),
      );
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const RegisterFormPage()),
        ],
      );
      await tester.pumpWidget(
        Provider<ExportRegisterCsvController>.value(
          value: export,
          child: MaterialApp.router(
            theme: lightTheme,
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Senha do registro'), findsOneWidget);
      expect(find.text('URL do site'), findsOneWidget);
      expect(find.text('App do celular (opcional)'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Nome, app ou site')).dy,
        lessThan(tester.getTopLeft(find.text('Usuário e senha')).dy),
      );
      expect(
        tester.getTopLeft(find.text('Usuário e senha')).dy,
        lessThan(tester.getTopLeft(find.text('App do celular (opcional)')).dy),
      );
      await tester.ensureVisible(find.text('Salvar'));
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await export.registerController.close();
      await export.close();
    },
  );
}

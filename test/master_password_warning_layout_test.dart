import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/welcome/master_password_warning_screen.dart';

void main() {
  testWidgets('tela da senha mestra rola em alturas reduzidas', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: MasterPasswordWarningScreen(masterPassword: 'senha-segura'),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('senha-segura'), findsNothing);
    expect(find.text('Senha oculta'), findsOneWidget);
    expect(find.text('Exportar QR Code'), findsNothing);
    await tester.tap(find.text('Mostrar por 15 segundos'));
    await tester.pump();
    expect(find.text('senha-segura'), findsOneWidget);
    await tester.pump(const Duration(seconds: 15));
    expect(find.text('senha-segura'), findsNothing);
    await tester.tap(find.text('Mostrar por 15 segundos'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('senha-segura'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('aviso temporário fecha ao continuar', (tester) async {
    bool? acknowledged;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                acknowledged = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const MasterPasswordWarningScreen(
                    masterPassword: 'senha-segura',
                  ),
                );
              },
              child: const Text('Abrir aviso'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir aviso'));
    await tester.pumpAndSettle();
    expect(find.text('senha-segura'), findsNothing);
    await tester.tap(find.text('Entendi e quero continuar'));
    await tester.pumpAndSettle();
    expect(acknowledged, true);
    expect(find.text('Guarde sua senha mestra'), findsNothing);
  });
}

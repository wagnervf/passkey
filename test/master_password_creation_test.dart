import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';
import 'package:keezy/src/modules/welcome/master_password_creation_screen.dart';

void main() {
  testWidgets('suggestions and rules stay in a visible help popup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: MasterPasswordCreationScreen()),
    );

    expect(find.text('Gerar Senha'), findsOneWidget);
    expect(find.text(MasterPasswordPolicy.guidance), findsNothing);
    expect(find.text('Gerar 8 caracteres'), findsNothing);
    expect(find.text('Continuar'), findsOneWidget);

    await tester.tap(find.text('Gerar Senha'));
    await tester.pumpAndSettle();
    expect(find.text(MasterPasswordPolicy.guidance), findsOneWidget);
    await tester.tap(find.text('Gerar 8 caracteres'));
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();
    final password = fields[1].controller!.text;
    expect(password.length, 8);
    expect(fields[2].controller!.text, password);
    final editableFields = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .toList();
    expect(editableFields[1].obscureText, isFalse);
    expect(
      find.text('Senha sugerida preenchida. Guarde-a antes de continuar.'),
      findsOneWidget,
    );
  });

  testWidgets('invalid fields report errors inline', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MasterPasswordCreationScreen()),
    );
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pump();

    expect(find.text('Informe seu nome para continuar.'), findsOneWidget);
    expect(find.text('Informe uma senha mestra.'), findsOneWidget);
    expect(find.text('Confirme a senha mestra.'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('master-name')), 'Ana');
    await tester.enterText(
      find.byKey(const ValueKey('master-password')),
      'curta',
    );
    await tester.enterText(
      find.byKey(const ValueKey('master-confirmation')),
      'curta',
    );
    await tester.pump();
    expect(
      find.text('A senha mestra deve ter pelo menos 8 caracteres.'),
      findsOneWidget,
    );
  });
}

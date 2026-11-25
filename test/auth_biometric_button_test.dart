import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/auth/pages/auth_form_senha_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('oferece biometria na tela de senha quando ela foi ativada', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'biometric_enabled': true});

    await tester.pumpWidget(const MaterialApp(home: AuthFormSenhaPage()));
    await tester.pump();

    expect(find.text('Entrar com biometria'), findsOneWidget);
    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
  });
}

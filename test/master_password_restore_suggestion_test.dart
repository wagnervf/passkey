import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/views/backup_restore_page.dart';

void main() {
  testWidgets('restore shows a generated master password before saving', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: BackupRestorePage(showExport: false)),
      ),
    );
    await tester.tap(find.text('Restaurar backup Keezy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sugerir senha de 20 caracteres'));
    await tester.pump();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[1].controller!.text.length, 20);
    expect(fields[2].controller!.text, fields[1].controller!.text);
    expect(fields[1].obscureText, isFalse);
    expect(
      find.text('Guarde a senha sugerida antes de continuar.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

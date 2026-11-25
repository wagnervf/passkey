import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/core/utils/password_field_with_generator.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository_impl.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository_impl.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('keezy-csv-roundtrip-');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('exportação completa e individual preservam todos os campos', () async {
    final original = RegisterModel(
      id: 'original',
      name: ' Nome, "com aspas" \n segunda linha ',
      url: ' https://exemplo.test/a,b?x="y" ',
      username: ' usuário 😀 ',
      password: '  senha,"com aspas"\nsegunda linha  ',
      note: ' nota, "citada"\ncom acentos: ação ',
    );
    final contents = <String>[];
    final exporter = ExportRegistersCsvRepositoryImpl(
      temporaryDirectory: () async => temp,
      share: (params) async {
        contents.add(await File(params.files!.single.path).readAsString());
        return const ShareResult('destino', ShareResultStatus.success);
      },
    );

    expect(await exporter.exportToCsv([original]), isTrue);
    await exporter.exportSingleRegisterCsv(original);
    expect(contents, hasLength(2));

    for (final csv in contents) {
      final imported = ImportRegistersCsvRepositoryImpl.parseCsv(csv);
      expect(imported, hasLength(1));
      expect(imported.single.name, original.name);
      expect(imported.single.url, original.url);
      expect(imported.single.username, original.username);
      expect(imported.single.password, original.password);
      expect(imported.single.note, original.note);
    }
  });

  test('importação conserva espaços mesmo no último campo e na senha', () {
    const csv =
        'name,url,username,password,note\r\n'
        'Site,,,  senha  ,nota final  \r\n'
        'Outro,,,   ,\r\n';

    final registers = ImportRegistersCsvRepositoryImpl.parseCsv(csv);
    expect(registers, hasLength(2));
    expect(registers[0].password, '  senha  ');
    expect(registers[0].note, 'nota final  ');
    expect(registers[1].password, '   ');
  });

  testWidgets('campo de senha aceita valores longos e preserva espaços', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    const password = '  senha com mais de dezesseis caracteres  ';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordFieldWithGenerator(
            controller: controller,
            generatedLength: 16,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), password);

    expect(controller.text, password);
    await tester.tap(find.text('Gerar Senha'));
    expect(controller.text.length, 16);
  });
}

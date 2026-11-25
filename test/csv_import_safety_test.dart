import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:keezy/src/core/hive/vault_key_manager.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/csv_import_preview.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_register_csv_controller.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:keezy/src/modules/import_registers_csv/pages/import_register_csv_page.dart';
import 'package:keezy/src/modules/import_registers_csv/repositories/import_registers_csv_repository_impl.dart';
import 'package:keezy/src/modules/import_registers_csv/services/import_registers_csv_services.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/register/repositories/register_repository_impl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class _Keys implements VaultKeyStore {
  String? envelope;
  @override
  Future<String?> readPasswordEnvelope() async => envelope;
  @override
  Future<void> writePasswordEnvelope(String value) async => envelope = value;
  @override
  Future<void> deletePasswordEnvelope() async => envelope = null;
  @override
  Future<String?> readLegacyKey() async => null;
  @override
  Future<void> deleteLegacyKey() async {}
  @override
  Future<String?> readBiometricKey() async => null;
  @override
  Future<void> writeBiometricKey(String value) async {}
  @override
  Future<void> deleteBiometricKey() async {}
  @override
  Future<String?> readDeletionMarker() async => null;
  @override
  Future<void> writeDeletionMarker() async {}
  @override
  Future<void> deleteDeletionMarker() async {}
}

class _FailAfterFirstWrite extends RegisterHive {
  bool failOnce = true;

  @override
  Future<void> addNewRegisters(List<RegisterModel> records) async {
    if (failOnce) {
      failOnce = false;
      await super.addNewRegisters([records.first]);
      throw StateError('simulated interrupted write');
    }
    await super.addNewRegisters(records);
  }
}

class _CsvService implements ImportRegistersCsvServices {
  _CsvService(this.rows);
  final List<RegisterModel> rows;

  @override
  Future<List<RegisterModel>> importFromCsv() async =>
      rows.map((row) => row.copyWith(id: const Uuid().v4())).toList();
}

void main() {
  test(
    'malformed CSV rows and duplicate headers are rejected before import',
    () {
      expect(
        () => ImportRegistersCsvRepositoryImpl.parseCsv(
          'name,url,username,password,note\nSite,,,senha',
        ),
        throwsFormatException,
      );
      expect(
        () => ImportRegistersCsvRepositoryImpl.parseCsv(
          'name,url,username,password,note,name\nSite,,,senha,,Outro',
        ),
        throwsFormatException,
      );
    },
  );

  test('preview skips exact duplicates and keeps changed passwords', () {
    final current = RegisterModel(
      id: 'old',
      name: 'Site',
      url: 'https://site.test',
      username: 'ana',
      password: 'one',
      note: '',
    );
    final changed = current.copyWith(id: 'changed', password: 'two');
    final preview = CsvImportPreview.create(
      current: [current],
      imported: [
        current.copyWith(id: 'duplicate'),
        changed,
        changed.copyWith(id: 'duplicate-in-file'),
      ],
    );

    expect(preview.totalInFile, 3);
    expect(preview.duplicates, 2);
    expect(preview.newCount, 1);
    expect(preview.toImport.single.password, 'two');
    expect(preview.matchesVault([current]), isTrue);
    expect(
      preview.matchesVault([current.copyWith(password: 'three')]),
      isFalse,
    );
    final whitespace = CsvImportPreview.create(
      current: [current],
      imported: [current.copyWith(id: 'spaces', name: 'Site ')],
    );
    expect(whitespace.newCount, 1);
  });

  group('CSV import with a real encrypted vault', () {
    late Directory directory;
    late RegisterHive vault;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('keezy-csv-import-');
      Hive.init(directory.path);
      RegisterHive.init(manager: VaultKeyManager(store: _Keys()));
      await RegisterHive.unlockWithPassword(
        'senha mestra teste',
        createIfMissing: true,
      );
      vault = RegisterHive();
      await vault.addRegister(
        RegisterModel(id: 'old', name: 'Antes', password: 'preserved'),
      );
    });

    tearDown(() async {
      await RegisterHive.lock();
      await Hive.close();
      await directory.delete(recursive: true);
    });

    test(
      'partial write is retryable after reopening without losing old data',
      () async {
        final failingHive = _FailAfterFirstWrite();
        final repository = RegisterRepositoryImpl(registerHive: failingHive);
        final records = RegisterController(registerRepository: repository);
        final csv = _CsvService([
          RegisterModel(id: 'a', name: 'Novo A', password: 'secret A'),
          RegisterModel(id: 'b', name: 'Novo B', password: 'secret B'),
        ]);
        final importer = ImportRegisterCsvController(
          importRegistersCsvServices: csv,
          registerController: records,
        );

        final first = (await importer.prepareImport())!;
        expect(first.newCount, 2);
        expect(await importer.commitImport(first), isFalse);
        expect(importer.state, isA<ImportCsvError>());
        expect(vault.getRegister('old')?.password, 'preserved');
        expect(vault.count(), 2);

        await RegisterHive.lock();
        await RegisterHive.unlockWithPassword('senha mestra teste');
        expect(vault.getRegister('old')?.password, 'preserved');
        expect(vault.count(), 2);

        final retry = (await importer.prepareImport())!;
        expect(retry.newCount, 1);
        expect(retry.duplicates, 1);
        expect(await importer.commitImport(retry), isTrue);
        expect(vault.count(), 3);
        expect(vault.getAllRegisters().map((record) => record.name).toSet(), {
          'Antes',
          'Novo A',
          'Novo B',
        });
        final repeat = (await importer.prepareImport())!;
        expect(repeat.newCount, 0);
        expect(repeat.duplicates, 2);
        await importer.close();
        await records.close();
      },
    );

    test('changed vault invalidates preview before any write', () async {
      final records = RegisterController(
        registerRepository: RegisterRepositoryImpl(),
      );
      final importer = ImportRegisterCsvController(
        importRegistersCsvServices: _CsvService([
          RegisterModel(id: 'new', name: 'Novo'),
        ]),
        registerController: records,
      );
      final preview = (await importer.prepareImport())!;
      await vault.addRegister(RegisterModel(id: 'other', name: 'Outro'));

      expect(await importer.commitImport(preview), isFalse);
      expect(vault.count(), 2);
      expect(vault.getAllRegisters().map((record) => record.name).toSet(), {
        'Antes',
        'Outro',
      });
      await importer.close();
      await records.close();
    });

    test('an imported ID can never overwrite an existing record', () async {
      await expectLater(
        vault.addNewRegisters([
          RegisterModel(id: 'old', name: 'Substituição indevida'),
        ]),
        throwsStateError,
      );
      expect(vault.getRegister('old')?.password, 'preserved');
      expect(vault.count(), 1);
    });

    testWidgets('preview requires confirmation before writing', (tester) async {
      final records = RegisterController(
        registerRepository: RegisterRepositoryImpl(),
      );
      final importer = ImportRegisterCsvController(
        importRegistersCsvServices: _CsvService([
          RegisterModel(id: 'new', name: 'Novo'),
        ]),
        registerController: records,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ImportRegisterCsvController>.value(
            value: importer,
            child: const Scaffold(body: ImportRegisterCsvPage()),
          ),
        ),
      );

      await tester.tap(find.text('Importar Registros'));
      await tester.pumpAndSettle();
      expect(find.text('Prévia da importação'), findsOneWidget);
      expect(find.text('Novos: 1'), findsOneWidget);
      expect(vault.count(), 1);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(vault.count(), 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await importer.close();
      await records.close();
    });
  });
}

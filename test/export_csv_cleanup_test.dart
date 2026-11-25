import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/export_registers_csv/repositories/export_registers_csv_repository_impl.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  late Directory temp;
  const secret = 'senha visível no csv';
  final registers = [RegisterModel(id: 'one', name: 'Site', password: secret)];

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('keezy-csv-test-');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('apaga o CSV depois de compartilhar com sucesso', () async {
    String? sharedPath;
    final repository = ExportRegistersCsvRepositoryImpl(
      temporaryDirectory: () async => temp,
      share: (params) async {
        sharedPath = params.files!.single.path;
        expect(await File(sharedPath!).readAsString(), contains(secret));
        expect(params.text, contains('CSV'));
        expect(params.text, contains('texto legível'));
        expect(params.text, isNot(contains('backup')));
        return const ShareResult('destino', ShareResultStatus.success);
      },
    );

    expect(await repository.exportToCsv(registers), isTrue);
    expect(await File(sharedPath!).exists(), isFalse);
  });

  test('apaga o CSV após cancelamento ou falha', () async {
    for (final status in [
      ShareResultStatus.dismissed,
      ShareResultStatus.unavailable,
      null,
    ]) {
      String? sharedPath;
      final repository = ExportRegistersCsvRepositoryImpl(
        temporaryDirectory: () async => temp,
        share: (params) async {
          sharedPath = params.files!.single.path;
          if (status == null) throw StateError('falha');
          return ShareResult('', status);
        },
      );

      if (status == null) {
        await expectLater(repository.exportToCsv(registers), throwsStateError);
      } else {
        expect(await repository.exportToCsv(registers), isFalse);
      }
      expect(await File(sharedPath!).exists(), isFalse);
    }
  });

  test('não compartilha arquivo quando não há registros', () async {
    var shareCalled = false;
    final repository = ExportRegistersCsvRepositoryImpl(
      temporaryDirectory: () async => temp,
      share: (_) async {
        shareCalled = true;
        return const ShareResult('destino', ShareResultStatus.success);
      },
    );

    await expectLater(repository.exportToCsv([]), throwsException);
    expect(shareCalled, isFalse);
  });

  test('apaga arquivos antigos ao iniciar novamente', () async {
    final folder = Directory('${temp.path}/keezy_exports');
    await folder.create();
    await File('${folder.path}/registros_antigos.csv').writeAsString(secret);

    await ExportRegistersCsvRepositoryImpl.cleanupStaleExports(
      temporaryDirectory: temp,
    );
    expect(await folder.exists(), isFalse);
  });

  test(
    'apaga arquivos temporários do modelo e do registro individual',
    () async {
      final paths = <String>[];
      final repository = ExportRegistersCsvRepositoryImpl(
        temporaryDirectory: () async => temp,
        share: (params) async {
          paths.add(params.files!.single.path);
          expect(await File(paths.last).exists(), isTrue);
          return const ShareResult('destino', ShareResultStatus.success);
        },
      );

      await repository.exportEmptyCsvTemplate();
      await repository.exportSingleRegisterCsv(registers.single);
      expect(paths, hasLength(2));
      for (final path in paths) {
        expect(await File(path).exists(), isFalse);
      }
    },
  );
}

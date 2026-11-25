import 'package:flutter_test/flutter_test.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/backup_merge_plan.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

void main() {
  test('mantém o cofre, ignora repetidos e resolve colisões de ID', () {
    final current = [
      RegisterModel(id: 'same', name: 'Atual', password: 'segredo'),
    ];
    final backup = [
      RegisterModel(id: 'old-id', name: 'Atual', password: 'segredo'),
      RegisterModel(id: 'same', name: 'Novo', password: 'outra senha'),
      RegisterModel(id: 'new', name: 'Terceiro'),
      RegisterModel(id: 'duplicate-in-file', name: 'Terceiro'),
    ];

    final plan = BackupMergePlan(current: current, imported: backup);
    expect(plan.duplicates, 2);
    expect(plan.toImport, hasLength(2));
    expect(plan.toImport.first.id, isNot('same'));
    expect(plan.toImport.first.password, 'outra senha');
    expect(plan.toImport.last.id, 'new');
    expect(current.single.id, 'same');

    final retry = BackupMergePlan(
      current: [...current, ...plan.toImport],
      imported: backup,
    );
    expect(retry.toImport, isEmpty);
  });
}

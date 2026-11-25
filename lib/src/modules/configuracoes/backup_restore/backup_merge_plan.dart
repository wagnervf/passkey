import 'dart:convert';

import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:uuid/uuid.dart';

/// Plans a repeatable import without overwriting records already in the vault.
class BackupMergePlan {
  BackupMergePlan({
    required List<RegisterModel> current,
    required List<RegisterModel> imported,
  }) {
    final seen = current.map(_contentKey).toSet();
    final ids = current.map((record) => record.id).toSet();
    final additions = <RegisterModel>[];
    var skipped = 0;
    for (final record in imported) {
      if (!seen.add(_contentKey(record))) {
        skipped++;
        continue;
      }
      var id = record.id;
      if (id.isEmpty || ids.contains(id)) {
        do {
          id = const Uuid().v4();
        } while (ids.contains(id));
      }
      ids.add(id);
      additions.add(id == record.id ? record : record.copyWith(id: id));
    }
    toImport = List.unmodifiable(additions);
    duplicates = skipped;
  }

  late final List<RegisterModel> toImport;
  late final int duplicates;

  static String _contentKey(RegisterModel record) {
    final content = Map<String, dynamic>.from(record.toMap())..remove('id');
    return jsonEncode(content);
  }

  static bool sameContent(RegisterModel a, RegisterModel b) =>
      _contentKey(a) == _contentKey(b);
}

import 'dart:convert';

import 'package:keezy/src/modules/register/model/register_model.dart';

/// Exact CSV content is the duplicate key. Different passwords or notes remain
/// separate records, and neither existing records nor their IDs are changed.
class CsvImportPreview {
  CsvImportPreview._(this._vaultSnapshot, {
    required this.totalInFile,
    required this.duplicates,
    required this.toImport,
  });

  final int totalInFile;
  final int duplicates;
  final List<RegisterModel> toImport;
  final String _vaultSnapshot;

  int get newCount => toImport.length;

  static CsvImportPreview create({
    required List<RegisterModel> imported,
    required List<RegisterModel> current,
  }) {
    final seen = current.map(_contentKey).toSet();
    final newRecords = <RegisterModel>[];
    var duplicates = 0;
    for (final record in imported) {
      if (seen.add(_contentKey(record))) {
        newRecords.add(record);
      } else {
        duplicates++;
      }
    }
    return CsvImportPreview._(
      _snapshot(current),
      totalInFile: imported.length,
      duplicates: duplicates,
      toImport: List.unmodifiable(newRecords),
    );
  }

  bool matchesVault(List<RegisterModel> current) =>
      _vaultSnapshot == _snapshot(current);

  static String _snapshot(List<RegisterModel> records) {
    final ordered = List<RegisterModel>.from(records)
      ..sort((a, b) => a.id.compareTo(b.id));
    return jsonEncode(
      ordered.map((record) => [record.id, _contentKey(record)]).toList(),
    );
  }

  static String _contentKey(RegisterModel record) => jsonEncode([
    record.name ?? '',
    record.url ?? '',
    record.username ?? '',
    record.password ?? '',
    record.note ?? '',
  ]);

  static bool hasSameContent(RegisterModel a, RegisterModel b) =>
      _contentKey(a) == _contentKey(b);
}

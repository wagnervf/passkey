import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/csv_import_preview.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_register_csv_controller.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:provider/provider.dart';

class ImportRegisterCsvPage extends StatefulWidget {
  const ImportRegisterCsvPage({super.key});

  @override
  State<ImportRegisterCsvPage> createState() => _ImportRegisterCsvPageState();
}

class _ImportRegisterCsvPageState extends State<ImportRegisterCsvPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ItemCardWithIcon(
            text: 'Importar Registros',
            subtTitle: 'Selecione um CSV para revisar antes de importar.',
            icon: Icons.upload_file_rounded,
            enabled: !_isLoading,
            onTap: _startImport,
          ),
        ),
        if (_isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Future<void> _startImport() async {
    if (_isLoading) return;
    final controller = context.read<ImportRegisterCsvController>();
    setState(() => _isLoading = true);
    final preview = await controller.prepareImport();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (preview == null) {
      final message = _messageForState(controller.state);
      if (message != null) ShowMessager.show(context, message);
      return;
    }

    final confirmed = await _confirmImport(preview);
    if (!mounted || confirmed != true) return;
    setState(() => _isLoading = true);
    final success = await controller.commitImport(preview);
    if (!mounted) return;
    setState(() => _isLoading = false);
    final message = _messageForState(controller.state);
    if (message != null) ShowMessager.show(context, message);
    if (success) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) context.go(RoutesPaths.home);
    }
  }

  String? _messageForState(ImportRegistersCsvState state) => switch (state) {
    ImportCsvLoaded(:final message) => message,
    ImportCsvError(:final message) => message,
    ImportCsvNull(:final message) => message,
    _ => null,
  };

  Future<bool?> _confirmImport(CsvImportPreview preview) => showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Prévia da importação'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No arquivo: ${preview.totalInFile}'),
            Text('Novos: ${preview.newCount}'),
            Text('Repetidos ignorados: ${preview.duplicates}'),
            const SizedBox(height: 12),
            const Text(
              'Os registros atuais serão mantidos. Nenhum registro será substituído.',
            ),
            if (preview.newCount == 0) ...[
              const SizedBox(height: 12),
              const Text('Todos os registros deste CSV já estão no cofre.'),
            ],
            if (preview.newCount > 0) ...[
              const SizedBox(height: 12),
              const Text('Primeiros registros novos:'),
              for (final record in preview.toImport.take(3))
                Text(
                  record.name?.isNotEmpty == true ? record.name! : 'Sem nome',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(preview.newCount == 0 ? 'Fechar' : 'Cancelar'),
        ),
        if (preview.newCount > 0)
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Importar ${preview.newCount} registro(s)'),
          ),
      ],
    ),
  );
}

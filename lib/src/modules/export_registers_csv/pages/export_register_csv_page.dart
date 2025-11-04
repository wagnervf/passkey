import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_registers_csv_state.dart';
import 'package:provider/provider.dart';

class ExportRegisterCsvPage extends StatefulWidget {
  const ExportRegisterCsvPage({super.key});

  @override
  State<ExportRegisterCsvPage> createState() => _ExportRegisterCsvPageState();
}

class _ExportRegisterCsvPageState extends State<ExportRegisterCsvPage> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExportRegisterCsvController>(
      context,
      listen: false,
    );

    return BlocConsumer<ExportRegisterCsvController, ExportRegistersCsvState>(
      listener: (context, state) {
        if (state is ExportCsvLoading) {
          _showLoadingDialog(context);
          return;
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is ExportCsvLoaded) {
          ShowMessager.show(context, '✅ Registros compartilhados com sucesso!');
          Navigator.of(context).pop();
        } else if (state is ExportCsvNull) {
          ShowMessager.show(
            context,
            '⚠️ Nenhum registro encontrado para exportar.',
          );
        } else if (state is ExportCsvError) {
          ShowMessager.show(context, '❌ ${state.message}');
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            ItemCardWithIcon(
              text: 'Exportar Registros',
              subtTitle:
                  'Exportará seus registros para um arquivo ".csv". Você poderá compartilhá-los diretamente.',
              icon: Icons.share,
              onTap: () => _showExportDialog(controller),
            ),

            ListTile(
              dense: true,
              title: Text(
                'Exportar Modelo CSV',
                style: Theme.of(context).textTheme.labelMedium),
              
              subtitle: Text(
                'Gere um arquivo CSV vazio para preencher manualmente e importar depois.',
              ),
              leading: Icon(
                Icons.download,
              ),
              onTap: () => _exportarModelo(controller),
            ),
          ],
        );
      },
    );
  }

  // Exporta apenas o modelo CSV vazio
  Future<void> _exportarModelo(ExportRegisterCsvController controller) async {
    await controller.exportEmptyTemplate();
  }

  void _showLoadingDialog(
    BuildContext context, {
    String message = 'Carregando...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(message, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showExportDialog(ExportRegisterCsvController controller) {
    return showDialog(
      barrierDismissible: true,
      useSafeArea: true,
      useRootNavigator: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exportar Registros'),
          content: const Text(
            'Os dados exportados poderão ser visualizados por qualquer pessoa que tenha acesso ao arquivo. '
            'Deseja realmente continuar com a exportação?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _exportarRegistros(controller);
              },
              child: const Text('Exportar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportarRegistros(
    ExportRegisterCsvController controller,
  ) async {
    try {
      await context.read<ExportRegisterCsvController>().exportFileCsv();
    } catch (e, s) {
      log('Erro ao exportar registros: $e', stackTrace: s);
      if (!context.mounted) return;
      ShowMessager.show(
        // ignore: use_build_context_synchronously
        context,
        '❌ Ocorreu um erro durante a exportação.',
      );
    }
  }
}

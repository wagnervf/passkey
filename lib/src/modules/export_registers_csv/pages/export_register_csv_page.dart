import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_registers_csv_state.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportRegisterCsvPage extends StatefulWidget {
  const ExportRegisterCsvPage({super.key});

  @override
  State<ExportRegisterCsvPage> createState() => _ExportRegisterCsvPageState();
}

class _ExportRegisterCsvPageState extends State<ExportRegisterCsvPage> {
  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<ExportRegisterCsvController>(context, listen: false);

    return BlocConsumer<ExportRegisterCsvController, ExportRegistersCsvState>(
      listener: (context, state) {
        if (state is ExportCsvLoading) {
          _showLoadingDialog(context);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is ExportCsvLoaded) {
          ShowMessager.show(context, 'Senhas exportadas com sucesso!');
          Navigator.of(context).pop();
        }
        if (state is ExportCsvError) {
          ShowMessager.show(context, state.message);
        } else {
          SizedBox.shrink();
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            ItemCardWithIcon(
              text: 'Exportar Registrosssss',
              subtTitle:
                  'Exportará suas senhas para um arquivo ".csv". Você poderá importá-las aqui ou no Chrome.',
              icon: Icons.file_download,
              onTap: () => _dialogExportar(controller),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final file = await context
                    .read<ExportRegisterCsvController>()
                    .exportFileCsv();

                if (file != null && await file.exists()) {
                  final params = ShareParams(
                    text: 'Aqui está o backup das suas senhas.',
                    subject: 'Backup de Senhas CSV',
                    files: [XFile(file.path)],
                  );

                  final result = await SharePlus.instance.share(params);

                  if (result.status == ShareResultStatus.success) {
                    log('Thank you for sharing the picture!');
                  }
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Falha ao exportar ou compartilhar o arquivo.')),
                  );
                }
              },
              icon: const Icon(Icons.share),
              label: const Text('Exportar e Compartilhar CSV'),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context,
      {String message = 'Carregando...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop:  false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _dialogExportar(ExportRegisterCsvController controller) {
    return showDialog(
        barrierDismissible: true,
        useSafeArea: true,
        useRootNavigator: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Exportar Senhas'),
            content: const Text(
                'Suas senhas ficarão expostas para qualquer pessoa que tenha acesso ao arquivo exportado. Você tem certeza que deseja continuar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  await _exportarSenhas(controller);
                },
                child: const Text('Exportar'),
              ),
            ],
          );
        });
  }

  _exportarSenhas(ExportRegisterCsvController controller) async {
    CircularProgressIndicator();
    await controller.exportFileCsv();

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

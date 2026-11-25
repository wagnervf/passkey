import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/auth_dialog_service.dart';
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
  bool _checkingAvailability = true;
  bool _hasRegisters = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final hasRegisters = await context
        .read<ExportRegisterCsvController>()
        .hasRegisters();
    if (mounted) {
      setState(() {
        _hasRegisters = hasRegisters;
        _checkingAvailability = false;
      });
    }
  }

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
        } else if (state is ExportCsvNull) {
          ShowMessager.show(context, '⚠️ ${state.message}');
        } else if (state is ExportCsvError) {
          ShowMessager.show(context, '❌ ${state.message}');
        }
      },
      builder: (context, state) {
        return ItemCardWithIcon(
          text: 'Exportar Registros',
          subtTitle: _checkingAvailability
              ? 'Verificando registros disponíveis...'
              : _hasRegisters
              ? 'Exportará seus registros para um arquivo ".csv".'
              : 'Adicione um registro para habilitar a exportação.',
          icon: Icons.share,
          enabled: !_checkingAvailability && _hasRegisters,
          onTap: () => _confirmarExportacao(context, controller),
        );
      },
    );
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

  Future<void> _confirmarExportacao(
    BuildContext context,
    ExportRegisterCsvController controller,
  ) async {
    final confirmou = await AuthDialogService.confirmarAcao(
      context: context,
      titulo: 'Compartilhar registros em CSV',
      mensagem:
          'O arquivo CSV contém todas as senhas em texto legível. '
          'Quem tiver acesso a ele poderá lê-las. Guarde o arquivo com cuidado.',
      textoConfirmar: 'Compartilhar',
    );

    if (!mounted) return;
    if (confirmou) {
      await _exportarRegistros(controller);
      await _loadAvailability();
    }
  }

  Future<void> _exportarRegistros(
    ExportRegisterCsvController controller,
  ) async {
    try {
      await controller.exportFileCsv();
    } catch (_) {
      log('Erro ao exportar registros.');
      if (!mounted) return;
      ShowMessager.show(context, '❌ Ocorreu um erro durante a exportação.');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_register_csv_controller.dart';
import 'package:keezy/src/modules/export_registers_csv/controllers/export_registers_csv_state.dart';
import 'package:provider/provider.dart';

class ExportExempleRegisterWidget extends StatefulWidget {
  const ExportExempleRegisterWidget({super.key});

  @override
  State<ExportExempleRegisterWidget> createState() =>
      _ExportExempleRegisterWidgetState();
}

class _ExportExempleRegisterWidgetState
    extends State<ExportExempleRegisterWidget> {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExportRegisterCsvController>(
      context,
      listen: false,
    );

    return BlocConsumer<ExportRegisterCsvController, ExportRegistersCsvState>(
      listener: (context, state) {
        if (state is ExportCsvLoading) {
          CircularProgressIndicator();
          return;
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is ExportCsvLoaded) {
          ShowMessager.show(
            context,
            '✅ Exemplo de Registros compartilhados com sucesso!',
          );
          Navigator.of(context).pop();
        } else if (state is ExportCsvNull) {
          ShowMessager.show(context, '⚠️ Erro ao exportar exemplo');
        } else if (state is ExportCsvError) {
          ShowMessager.show(context, '❌ ${state.message}');
        }
      },
      builder: (context, state) {
        return ListTile(
          dense: true,
          title: Text(
            'Exportar Modelo CSV',
            style: Theme.of(context).textTheme.labelMedium,
          ),

          subtitle: Text(
            'Gere um arquivo CSV vazio para preencher manualmente e importar depois.',
          ),
          leading: Icon(Icons.download),
          onTap: () => _exportarModelo(controller),
        );
      },
    );
  }

  // Exporta apenas o modelo CSV vazio
  Future<void> _exportarModelo(ExportRegisterCsvController controller) async {
    await controller.exportEmptyTemplate();
  }
}

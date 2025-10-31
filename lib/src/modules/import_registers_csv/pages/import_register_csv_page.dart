import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_register_csv_controller.dart';
import 'package:keezy/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:provider/provider.dart';

class ImportRegisterCsvPage extends StatefulWidget {
  const ImportRegisterCsvPage({super.key});

  @override
  State<ImportRegisterCsvPage> createState() => _ImportRegisterCsvPageState();
}

class _ImportRegisterCsvPageState extends State<ImportRegisterCsvPage> {
  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<ImportRegisterCsvController>(context, listen: false);

    return BlocConsumer<ImportRegisterCsvController, ImportRegistersCsvState>(
      listener: (context, state) {
        if (state is ImportCsvLoading) {
          _showLoadingDialog(context);
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is ImportCsvLoaded) {
          ShowMessager.show(context, state.message);
          Navigator.of(context).pop();
        }
        if (state is ImportCsvError) {
          ShowMessager.show(context, state.message);
        } else {
          SizedBox.shrink();
        }
      },
      builder: (context, state) {
        return ItemCardWithIcon(
          text: 'Importar Registros',
          subtTitle:
              'Selecione um arquivo ".csv" que contém suas senhas para importá-las.',
          icon: Icons.upload_file,
          onTap: () => _restoreBackup(controller),
        );
      },
    );
  }

  void _restoreBackup(ImportRegisterCsvController controller) async {
    await controller.restoreBackupFromFileCsv();
  }

  void _showLoadingDialog(BuildContext context,
      {String message = 'Carregando...'}) {
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

}








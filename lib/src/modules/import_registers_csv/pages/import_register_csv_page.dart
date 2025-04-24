import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passkey/src/core/components/item_card_with_icon.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/modules/import_registers_csv/controllers/import_register_csv_controller.dart';
import 'package:passkey/src/modules/import_registers_csv/controllers/import_registers_csv_state.dart';
import 'package:provider/provider.dart';

class ImportRegisterCsvPage extends StatefulWidget {
  const ImportRegisterCsvPage({super.key});

  @override
  State<ImportRegisterCsvPage> createState() => _ImportRegisterCsvPageState();
}

class _ImportRegisterCsvPageState extends State<ImportRegisterCsvPage> {
  @override
  Widget build(BuildContext context) {
    final exportarImportarService =
        Provider.of<ImportRegisterCsvController>(context, listen: false);

    return BlocConsumer<ImportRegisterCsvController, ImportRegistersCsvState>(
      listener: (context, state) {
        if (state is ImportCsvLoaded) {
          ShowMessager.show(
            context,
            'Backup realizado com sucesso!',
          );
        } else if (state is ImportCsvError) {
          ShowMessager.show(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is ImportCsvLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // ItemCardWithIcon(
            //     text: 'Exportar Registros',
            //     subtTitle: 'Exportar registros para o Google Drive',
            //     icon: Icons.download,
            //     onTap: () => buttonExport(exportarImportarService)),
            ItemCardWithIcon(
              text: 'Importar Registros',
              subtTitle: 'Selecione um arquivo ".csv" que contém suas senhas prar importá-las.',
              icon: Icons.upload_file,
              onTap: () => _restoredBackup(
                context,
                exportarImportarService,
              ),
            ),
            
            //onTap: () => _restoredBackup(context, exportarImportarService)),
          ],
        );
      },
    );
  }

  // buttonExport(ImportRegisterCsvController exportarImportarService) async {
  //   CircularProgressIndicator();
  //   await Future.delayed(const Duration(seconds: 2));
  //   final String status = await exportarImportarService.exportBackup();

  //   if (mounted) {
  //     ShowMessager.show(context, status.toString());
  //   }
  // }

  void _restoredBackup(BuildContext context,
      ImportRegisterCsvController exportarImportarService) async {
    // final authController = context.read<AuthController>();
    // final registerController = context.read<RegisterController>();

    //final result = await exportarImportarService.restoreBackup(authController, registerController);
    final result = await exportarImportarService.restoreBackupFromFileCsv();

    if (!mounted) return; // Evita erro se o widget foi desmontado

    // if (context.mounted) {
    //   ShowMessager.show(
    //       context,
    //       result != null
    //           ? 'Importação concluída!'
    //           : 'Erro ao importar os dados.');
    // }
  }
}

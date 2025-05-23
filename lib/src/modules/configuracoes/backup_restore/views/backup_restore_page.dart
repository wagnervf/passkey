import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:provider/provider.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  @override
  Widget build(BuildContext context) {
    final exportarImportarService =
        Provider.of<BackupRestoreController>(context, listen: false);

    return BlocConsumer<BackupRestoreController, BackupRestoreState>(
      listener: (context, state) {
        if (state is BackupRestoreStateSuccessState) {
          ShowMessager.show(
            context,
            'Backup realizado com sucesso!',
          );
        } else if (state is BackupRestoreStateErrorState) {
          ShowMessager.show(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is BackupRestoreStateLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            ItemCardWithIcon(
                text: 'Exportar Registros',
                subtTitle: 'Exportar registros para o Google Drive',
                icon: Icons.download,
                onTap: () => buttonExport(exportarImportarService)),
            ItemCardWithIcon(
                text: 'Importar Registros',
                subtTitle: 'Importar registros do Google Drive',
                icon: Icons.upload_file,
                onTap: () => _restoredBackup(context, exportarImportarService)),
                //onTap: () => _restoredBackup(context, exportarImportarService)),
          ],
        );
      },
    );
  }

  buttonExport(BackupRestoreController exportarImportarService) async {
    CircularProgressIndicator();
    await Future.delayed(const Duration(seconds: 2));
    final String status = await exportarImportarService.exportBackup();

    if (mounted) {
      ShowMessager.show(context, status.toString());
    }
  }

  void _restoredBackup(BuildContext context,
      BackupRestoreController exportarImportarService) async {
  //  final authController = context.read<AuthController>();
//    final registerController = context.read<RegisterController>();

    //final result = await exportarImportarService.restoreBackup(authController, registerController);
 //   final result = await exportarImportarService.importCsv();

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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
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
    final controller = Provider.of<ImportRegisterCsvController>(
      context,
      listen: false,
    );

    return BlocConsumer<ImportRegisterCsvController, ImportRegistersCsvState>(
      listener: (context, state) async {
        if (state is ImportCsvLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is ImportCsvLoaded) {
          if (!mounted) return;
          ShowMessager.show(context, state.message);

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            context.go(RoutesPaths.home);
          }
        }

        if (state is ImportCsvError) {
          ShowMessager.show(context, state.message);
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Center(
              child: ItemCardWithIcon(
                text: 'Importar Registros',
                subtTitle:
                    'Selecione um arquivo ".csv" contendo seus registros exportados. ',
                icon: Icons.upload_file_rounded,
                onTap: _isLoading ? () {} : () => _restoreBackup(controller),
              ),
            ),
            if (_isLoading) _buildLoadingOverlay(),
          ],
        );
      },
    );
  }

  bool _isPickingFile = false;

  Future<void> _restoreBackup(ImportRegisterCsvController controller) async {
    if (_isPickingFile) return;
    _isPickingFile = true;

    try {
      await controller.restoreBackupFromFileCsv();
    } finally {
      _isPickingFile = false;
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(green: 0, red: 0),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Importando registros...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// The Keezy backup format is not ready for export or restoration yet.
class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Backup Keezy ainda não disponível'),
          subtitle: const Text(
            'Para transferir registros, use Exportar CSV e Importar CSV em '
            'Configurações. O arquivo CSV contém senhas legíveis; guarde-o '
            'com cuidado.',
          ),
        ),
      ),
    );
  }
}

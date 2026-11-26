// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/biometric_switch_widget.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/utils/utils.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/configuracoes/views/widgets/icon_change_theme.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/views/backup_restore_page.dart';
import 'package:keezy/src/modules/export_registers_csv/pages/export_exemple_register_widget.dart';
import 'package:keezy/src/modules/export_registers_csv/pages/export_register_csv_page.dart';
import 'package:keezy/src/modules/import_registers_csv/pages/import_register_csv_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(child: body(context)),
    );
  }

  BlocBuilder body(BuildContext context) {
    final int currentYear = DateTime.now().year;
    return BlocBuilder<AuthController, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AuthSuccessState) {
          return _body(context, currentYear);
        } else if (state is AuthErrorState) {
          return Text('Erro: ${state.message}');
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _body(BuildContext context, int currentYear) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Utils.titleCard(context, 'Opções'),
          const SizedBox(height: 10),
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const BiometricSwitchWidget(),
                _divider(),
                const IconChangeTheme(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Utils.titleCard(context, 'Gerenciar Registros'),
          const SizedBox(height: 10),
          Card(
            key: const ValueKey('manage-records-card'),
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                const ExportRegisterCsvPage(),
                _divider(),
                const ImportRegisterCsvPage(),
                _divider(),
                const ExportExempleRegisterWidget(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Utils.titleCard(context, 'Backup Keezy'),
          const SizedBox(height: 10),
          const BackupRestorePage(showRestore: false, showImport: true),
          const SizedBox(height: 72),
          Card(
            key: const ValueKey('delete-all-data-card'),
            elevation: 0,
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: () => _confirmarExclusao(context),
              leading: Icon(Icons.dangerous_outlined, color: Colors.red[800]),
              title: Text(
                'Excluir todos os dados',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: Colors.red[800]),
              ),
              subtitle: Text(
                'Apagar do celular todos os dados do aplicativo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '© $currentYear keezy seu gerenciador de senhas particular e privativo. Todos os direitos reservados.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Padding _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(thickness: 1),
    );
  }

  // Modal de confirmação antes de excluir a conta
  void _confirmarExclusao(BuildContext context) {
    var backupConfirmed = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Excluir todos os dados'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O cofre e a conta neste aparelho serão apagados. '
                  'Esta ação não pode ser desfeita.',
                ),
                const SizedBox(height: 12),
                Text(
                  'Para restaurar seus registros depois, guarde um backup '
                  'Keezy protegido (.keezy) e a senha desse backup.',
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('O CSV contém senhas legíveis e não é protegido.'),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: backupConfirmed,
                  onChanged: (value) =>
                      setDialogState(() => backupConfirmed = value ?? false),
                  title: const Text(
                    'Guardei um backup Keezy protegido ou aceito perder estes dados.',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: backupConfirmed
                  ? () async {
                      Navigator.pop(dialogContext);
                      final result = await context
                          .read<AuthController>()
                          .logoutAndRemoveUser();
                      if (!context.mounted) return;

                      if (result) {
                        ShowMessager.show(
                          context,
                          'Usuário removido com sucesso.',
                        );
                        GoRouter.of(context)
                            .pushReplacement(RoutesPaths.splash);
                      } else {
                        ShowMessager.show(
                          context,
                          'Erro ao tentar remover o usuário. Tente novamente.',
                        );
                      }
                    }
                  : null,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        ),
      ),
    );
  }

  ColoredBox profile(BuildContext context, AuthUserModel? userLoged) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.onSecondary,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        leading: CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        title: Text(
          userLoged?.name ?? '',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

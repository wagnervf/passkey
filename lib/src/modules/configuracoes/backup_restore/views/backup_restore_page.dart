import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:keezy/src/modules/configuracoes/backup_restore/controllers/backup_restore_state.dart';
import 'package:provider/provider.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({
    super.key,
    this.showExport = true,
    this.showRestore = true,
    this.showImport = false,
  });

  final bool showExport;
  final bool showRestore;
  final bool showImport;

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  bool _processing = false;
  String? _progressMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey('backup-card'),
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          if (widget.showExport)
            ItemCardWithIcon(
              enabled: !_processing,
              icon: Icons.upload_file_outlined,
              text: 'Criar backup Keezy',
              subtTitle: 'Proteja seus registros com uma senha de backup.',
              onTap: _export,
            ),
          if (widget.showExport && (widget.showRestore || widget.showImport))
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(thickness: 1),
            ),
          if (widget.showRestore)
            ItemCardWithIcon(
              enabled: !_processing,
              icon: Icons.download_outlined,
              text: 'Restaurar backup Keezy',
              subtTitle: 'Crie um novo cofre a partir de um arquivo .keezy.',
              onTap: _restore,
            ),
          if (widget.showImport)
            ItemCardWithIcon(
              enabled: !_processing,
              icon: Icons.download_outlined,
              text: 'Restaurar backup Keezy',
              subtTitle: 'Adiciona registros ao cofre atual sem substituir os existentes.',
              onTap: _importIntoCurrentVault,
            ),
          if (_processing)
            Padding(
              key: const ValueKey('backup-progress'),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_progressMessage ?? 'Aguarde...')),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    final password = await _askPassword(
      title: 'Proteger backup',
      description: 'Defina uma senha de backup com pelo menos 10 caracteres.',
      confirmation: true,
    );
    if (password == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _processing = true;
      _progressMessage = 'Criando backup protegido...';
    });
    final error = await context.read<BackupRestoreController>().exportBackup(
      password,
    );
    if (mounted) {
      setState(() {
        _processing = false;
        _progressMessage = null;
      });
    }
    if (messenger.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text(error ?? 'Backup compartilhado com sucesso.')),
      );
    }
  }

  Future<void> _restore() async {
    final credentials = await _askRestoreCredentials();
    if (credentials == null || !mounted) return;
    setState(() {
      _processing = true;
      _progressMessage = 'Restaurando backup...';
    });
    final error = await context.read<BackupRestoreController>().restoreBackup(
      authController: context.read<AuthController>(),
      backupPassword: credentials.backupPassword,
      newMasterPassword: credentials.newMasterPassword,
    );
    if (!mounted) return;
    setState(() {
      _processing = false;
      _progressMessage = null;
    });
    ShowMessager.show(context, error ?? 'Backup restaurado com sucesso.');
    if (error == null) context.go(RoutesPaths.home);
  }

  Future<void> _importIntoCurrentVault() async {
    final password = await _askPassword(
      title: 'Restaurar backup',
      description:
          'Digite a senha do arquivo .keezy. '
          'Os registros atuais serão mantidos.',
      confirmation: false,
    );
    if (password == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final colors = Theme.of(context).colorScheme;
    final controller = context.read<BackupRestoreController>();
    setState(() {
      _processing = true;
      _progressMessage = 'Selecionando e restaurando backup...';
    });
    final message = await controller.importBackupIntoCurrentVault(password);
    if (mounted) {
      setState(() {
        _processing = false;
        _progressMessage = null;
      });
    }
    if (message != null && messenger.mounted) {
      final success = controller.state is BackupRestoreStateSuccessState;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: success ? colors.primary : colors.error,
          content: Text(
            message,
            style: TextStyle(
              color: success ? colors.onPrimary : colors.onError,
            ),
          ),
        ),
      );
    }
  }

  Future<String?> _askPassword({
    required String title,
    required String description,
    required bool confirmation,
  }) => showDialog<String>(
    context: context,
    builder: (_) => _BackupPasswordDialog(
      title: title,
      description: description,
      confirmation: confirmation,
    ),
  );

  Future<_RestoreCredentials?> _askRestoreCredentials() =>
      showDialog<_RestoreCredentials>(
        context: context,
        builder: (_) => const _RestoreCredentialsDialog(),
      );
}

class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog({
    required this.title,
    required this.description,
    required this.confirmation,
  });

  final String title;
  final String description;
  final bool confirmation;

  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.description),
          const SizedBox(height: 12),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha de backup'),
          ),
          if (widget.confirmation)
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmar senha'),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (_password.text.length < 10) {
            setState(
              () => _error =
                  'A senha do backup deve ter pelo menos 10 caracteres.',
            );
            return;
          }
          if (widget.confirmation && _password.text != _confirm.text) {
            setState(() => _error = 'As senhas do backup não coincidem.');
            return;
          }
          Navigator.pop(context, _password.text);
        },
        child: const Text('Continuar'),
      ),
    ],
  );
}

class _RestoreCredentialsDialog extends StatefulWidget {
  const _RestoreCredentialsDialog();

  @override
  State<_RestoreCredentialsDialog> createState() =>
      _RestoreCredentialsDialogState();
}

class _RestoreCredentialsDialogState extends State<_RestoreCredentialsDialog> {
  final _backupPassword = TextEditingController();
  final _masterPassword = TextEditingController();
  final _confirmMasterPassword = TextEditingController();
  String? _error;
  bool _showMasterPassword = false;
  bool _suggestedPassword = false;

  @override
  void dispose() {
    _backupPassword.dispose();
    _masterPassword.dispose();
    _confirmMasterPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Restaurar backup'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Selecione o arquivo depois de confirmar as senhas.'),
          const SizedBox(height: 8),
          const Text(MasterPasswordPolicy.guidance),
          TextField(
            controller: _backupPassword,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha do backup'),
          ),
          TextField(
            controller: _masterPassword,
            obscureText: !_showMasterPassword,
            decoration: InputDecoration(
              labelText: 'Nova senha mestra',
              suffixIcon: IconButton(
                tooltip: _showMasterPassword
                    ? 'Ocultar senha'
                    : 'Mostrar senha',
                onPressed: () => setState(() {
                  _showMasterPassword = !_showMasterPassword;
                }),
                icon: Icon(
                  _showMasterPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final suggestion = MasterPasswordPolicy.generate(length: 20);
              setState(() {
                _masterPassword.text = suggestion;
                _confirmMasterPassword.text = suggestion;
                _showMasterPassword = true;
                _suggestedPassword = true;
                _error = null;
              });
            },
            child: const Text('Sugerir senha de 20 caracteres'),
          ),
          if (_suggestedPassword)
            const Text('Guarde a senha sugerida antes de continuar.'),
          TextField(
            controller: _confirmMasterPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirmar nova senha mestra',
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          final policyError = MasterPasswordPolicy.validate(
            _masterPassword.text,
          );
          if (_backupPassword.text.length < 10 ||
              policyError != null ||
              _masterPassword.text != _confirmMasterPassword.text) {
            setState(() {
              _error = _backupPassword.text.length < 10
                  ? 'A senha do backup deve ter pelo menos 10 caracteres.'
                  : policyError ?? 'As senhas mestras não coincidem.';
            });
            return;
          }
          Navigator.pop(
            context,
            _RestoreCredentials(_backupPassword.text, _masterPassword.text),
          );
        },
        child: const Text('Selecionar arquivo'),
      ),
    ],
  );
}

class _RestoreCredentials {
  const _RestoreCredentials(this.backupPassword, this.newMasterPassword);

  final String backupPassword;
  final String newMasterPassword;
}

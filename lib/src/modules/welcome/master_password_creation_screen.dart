import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/help/help_view.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/utils/password_field_with_generator.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/security/master_password_policy.dart';
import 'package:keezy/src/modules/welcome/master_password_warning_screen.dart';

class MasterPasswordCreationScreen extends StatefulWidget {
  const MasterPasswordCreationScreen({super.key});

  @override
  State<MasterPasswordCreationScreen> createState() =>
      _MasterPasswordCreationScreenState();
}

class _MasterPasswordCreationScreenState
    extends State<MasterPasswordCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _generatedPassword = false;
  bool _submitted = false;
  bool _creatingAccount = false;
  String? _submitError;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _suggestPassword(int length) {
    final password = MasterPasswordPolicy.generate(length: length);
    setState(() {
      _passwordController.text = password;
      _confirmationController.text = password;
      _showPassword = true;
      _generatedPassword = true;
      _submitError = null;
    });
    if (_submitted) _formKey.currentState?.validate();
  }

  Future<void> _showPasswordHelp() async {
    FocusScope.of(context).unfocus();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gerar senha mestra'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(MasterPasswordPolicy.guidance),
              const SizedBox(height: 20),
              const Text('Escolha o tamanho da senha aleatória:'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _suggestPassword(8);
                  },
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Gerar 8 caracteres'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _suggestPassword(16);
                  },
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Gerar 16 caracteres'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A sugestão preenche os dois campos. Guarde a senha antes de continuar.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              HelpView.mostrarDialogCriarConta(context);
            },
            child: const Text('Por que preciso dela?'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
      _submitError = null;
    });
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _creatingAccount = true);
    final controller = context.read<AuthController>();
    final password = _passwordController.text;
    try {
      final saved = await controller.registerUser(
        AuthUserModel(
          password: password,
          name: _nameController.text.trim(),
          email: '',
        ),
      );
      if (!mounted) return;
      if (saved) {
        _passwordController.clear();
        _confirmationController.clear();
        final acknowledged = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => MasterPasswordWarningScreen(masterPassword: password),
        );
        if (mounted && acknowledged == true) {
          context.go(RoutesPaths.biometricSetup);
        }
      } else {
        final state = controller.state;
        setState(() {
          _submitError = state is AuthErrorState
              ? state.message
              : 'Não foi possível criar o cofre. Tente novamente.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitError = 'Não foi possível criar o cofre. Tente novamente.';
        });
      }
    } finally {
      if (mounted) setState(() => _creatingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta'), centerTitle: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.key_rounded,
                            color: colors.onPrimaryContainer,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Crie sua senha mestra',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ela protege seu cofre. Guarde-a em um lugar seguro.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _fieldLabel('Nome'),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('master-name'),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                        decoration: _fieldDecoration(
                          hint: 'Como podemos chamar você?',
                          icon: Icons.person_outline,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Informe seu nome para continuar.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _fieldLabel('Senha mestra'),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('master-password'),
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        decoration: _fieldDecoration(
                          hint: 'Crie uma senha',
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            tooltip: _showPassword
                                ? 'Ocultar senha'
                                : 'Mostrar senha',
                            onPressed: () => setState(() {
                              _showPassword = !_showPassword;
                            }),
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        onChanged: (_) {
                          if (_generatedPassword) {
                            setState(() => _generatedPassword = false);
                          }
                          if (_submitted &&
                              _confirmationController.text.isNotEmpty) {
                            _formKey.currentState?.validate();
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe uma senha mestra.';
                          }
                          return MasterPasswordPolicy.validate(value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PasswordGeneratorButton(
                          onPressed: _showPasswordHelp,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _fieldLabel('Confirmar senha mestra'),
                      const SizedBox(height: 6),
                      TextFormField(
                        key: const ValueKey('master-confirmation'),
                        controller: _confirmationController,
                        obscureText: !_showConfirmation,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        onFieldSubmitted: (_) {
                          if (!_creatingAccount) _submit();
                        },
                        decoration: _fieldDecoration(
                          hint: 'Digite a senha novamente',
                          icon: Icons.lock_reset_outlined,
                          suffix: IconButton(
                            tooltip: _showConfirmation
                                ? 'Ocultar confirmação'
                                : 'Mostrar confirmação',
                            onPressed: () => setState(() {
                              _showConfirmation = !_showConfirmation;
                            }),
                            icon: Icon(
                              _showConfirmation
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirme a senha mestra.';
                          }
                          if (value != _passwordController.text) {
                            return 'As senhas não coincidem.';
                          }
                          return null;
                        },
                      ),
                      if (_generatedPassword) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Senha sugerida preenchida. Guarde-a antes de continuar.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (_submitError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _submitError!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ],
                      const Spacer(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: _creatingAccount ? null : _submit,
                          icon: _creatingAccount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward),
                          label: Text(
                            _creatingAccount ? 'Criando cofre...' : 'Continuar',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: Theme.of(context).textTheme.labelLarge
        ?.copyWith(fontWeight: FontWeight.w600),
  );

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    suffixIcon: suffix,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}

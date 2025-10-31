// master_password_creation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/help/help_view.dart';
import 'package:keezy/src/core/components/show_sucess.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';

class MasterPasswordCreationScreen extends StatefulWidget {
  const MasterPasswordCreationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MasterPasswordCreationScreenState createState() =>
      _MasterPasswordCreationScreenState();
}

class _MasterPasswordCreationScreenState
    extends State<MasterPasswordCreationScreen> {
  final TextEditingController _createPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscureCreatePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _nameError;

  @override
  void dispose() {
    _createPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Function to validate passwords
  bool _validatePasswords() {
    setState(() {
      _passwordError = null;
      _nameError = null;
    });

    if (_createPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Ambos os campos de senha são obrigatórios.';
      });
      return false;
    }

    if (_createPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'As senhas não coincidem. Por favor, verifique.';
      });
      return false;
    }

    if (_createPasswordController.text.length < 6) {
      setState(() {
        _passwordError = 'A senha deve ter pelo menos 6 caracteres.';
      });
      return false;
    }

    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = 'Informe seu nome para continuar';
      });
      return false;
    }

    return true;
  }

  Future<void> _sendDataToController(String masterPassword) async {
    final controller = context.read<AuthController>();

    if (_formKey.currentState!.validate()) {
      final user = AuthUserModel(
        password: masterPassword,
        name: _nameController.text,
        email: '',
      );

      if (!mounted) return;

      try {
        await controller.limparContaAntesDeCriarUser();
        await controller.registerUser(user);
        if (mounted) {
          context.push(RoutesPaths.biometricSetup);
        }
      } catch (e) {
        if (mounted) {
          DialogUtils.showSuccessDialog(
            context,
            'Erro ao realizar cadastro: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crie sua Senha Mestra'),
        centerTitle: true,),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.vpn_key,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 24),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Senha Mestra é a ',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                        TextSpan(
                          text: 'chave para todos os seus dados',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                        TextSpan(
                          text:
                              '. A única senha que você precisará lembrar.\nGuarde-a bem!',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.person),
                    ),
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  SizedBox(height: 22),
                  TextField(
                    controller: _createPasswordController,
                    obscureText: _obscureCreatePassword,
                    decoration: InputDecoration(
                      labelText: 'Criar Senha',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCreatePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCreatePassword = !_obscureCreatePassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) => setState(() => _passwordError = null),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Senha',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (_) => setState(() => _passwordError = null),
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_validatePasswords()) {
                          await _sendDataToController(
                              _createPasswordController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Continuar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.help,
                      size: 16,
                    ),
                    label: Text('Porque devo criar uma conta?'),
                    onPressed: () => HelpView.mostrarDialogCriarConta(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

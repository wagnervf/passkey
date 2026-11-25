// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/form_field_input_password.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthFormSenhaPage extends StatefulWidget {
  const AuthFormSenhaPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthFormSenhaPage> {
  final _passwordController = TextEditingController();
  final _formKeyAuth = GlobalKey<FormState>();
  bool _biometricEnabled = false;
  bool _biometricInProgress = false;
  bool _passwordInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _biometricEnabled = preferences.getBool('biometric_enabled') ?? false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.clear();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acesso com Senha"),
        toolbarHeight: 60,
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  SingleChildScrollView _body(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKeyAuth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4.0),
                margin: const EdgeInsets.all(2.0),
                height: size.height * .1,
                child: Image.asset(
                  'assets/images/passkey.png',
                  fit: BoxFit.scaleDown,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Digite sua Senha Mestra",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              SizedBox(height: size.height * .2),
              FormFieldInputPassword(
                passwordController: _passwordController,
                copy: false,
              ),
              SizedBox(height: 20),
              buttonEntrar(context),
              if (_biometricEnabled) ...[
                const SizedBox(height: 12),
                buttonBiometria(context),
              ],
              SizedBox(height: size.height * .1),
              buttonEsqueciSenha(size, context),
              SizedBox(height: size.height * .1),
            ],
          ),
        ),
      ),
    );
  }

  Align buttonEsqueciSenha(Size size, BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SizedBox(
        child: TextButton(
          child: Text(
            "Esqueci minha senha",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          onPressed: () => {},
        ),
      ),
    );
  }

  SizedBox buttonEntrar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: FilledButton.icon(
        label: const Text(
          "Entrar",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        style: ButtonStyle(
          alignment: Alignment.center,
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          ),
        ),
        icon: const Icon(Icons.login, size: 30, color: Colors.white),
        onPressed: _passwordInProgress ? null : () => _login(context),
      ),
    );
  }

  SizedBox buttonBiometria(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _biometricInProgress ? null : _loginWithBiometrics,
        icon: _biometricInProgress
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.fingerprint),
        label: Text(
          _biometricInProgress ? 'Verificando...' : 'Entrar com biometria',
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ShowMessager.show(context, 'Por favor, insira sua senha');
      return;
    }
    setState(() => _passwordInProgress = true);
    final controller = context.read<AuthController>();
    final loggedIn = await controller.login(password);
    if (!context.mounted) return;
    setState(() => _passwordInProgress = false);
    if (loggedIn) {
      _passwordController.clear();
      GoRouter.of(context).go(RoutesPaths.home);
    } else {
      final state = controller.state;
      ShowMessager.show(
        context,
        state is AuthErrorState
            ? state.message
            : 'Não foi possível entrar. Confira sua senha.',
      );
    }
  }

  Future<void> _loginWithBiometrics() async {
    setState(() => _biometricInProgress = true);
    final loggedIn = await context.read<AuthController>().loginWithBiometrics();
    if (!mounted) return;
    setState(() => _biometricInProgress = false);
    if (loggedIn) {
      GoRouter.of(context).go(RoutesPaths.home);
    } else {
      ShowMessager.show(
        context,
        'Não foi possível entrar com biometria. Use sua senha mestra.',
      );
    }
  }
}

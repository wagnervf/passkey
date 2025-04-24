// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/form_field_input_password.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final _passwordController = TextEditingController();
  final _formKeyAuth = GlobalKey<FormState>();

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'Senha obrigatória'),
    MinLengthValidator(6,
        errorText: 'Sua senha deve possuir pelo menos 6 dígitos'),
  ]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
        ),
        body: _blocCosumer());
  }

  BlocConsumer<AuthController, AuthState> _blocCosumer() {
    return BlocConsumer<AuthController, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          Future.delayed(const Duration(milliseconds: 500)).then(
            (value) => GoRouter.of(context).pushReplacement(
              RoutesPaths.home,
              extra: state.user,
            ),
          );
        } else if (state is AuthErrorState) {
          ShowMessager.show(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }
        return mounted
            ? _formLogin(context)
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Form _formLogin(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Form(
      key: _formKeyAuth,
      child: LayoutBuilder(builder: (context, constraint) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      margin: const EdgeInsets.all(2.0),
                      height: size.height * .2,
                      child: Image.asset(
                        'assets/images/passkey.png',
                        fit: BoxFit.scaleDown,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                        padding: EdgeInsets.only(left: 28.0),
                        child: ListTile(
                          
                          title: Text(
                            "Acessar",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                          subtitle: Text(
                            "Armazenamento criptografado e acesso fácil quando precisar",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )),
                    const SizedBox(height: 24),
                    buttoBiometria(context),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28.0),
                      child: const Center(
                        child: Text(
                          ' ou ',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    FormFieldInputPassword(
                      passwordController: _passwordController,
                      copy: false,
                    ),
                    const SizedBox(height: 10),
                    buttonEntrar(context),
                    const SizedBox(height: 5),
                    buttonEsqueciSenha(size, context),
                    const Spacer(),
                    buttonCriarConta(context),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  buttonEsqueciSenha(Size size, BuildContext context) {
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

  SizedBox buttonCriarConta(BuildContext context) {
    return SizedBox(
      child: TextButton(
        child: Text(
          "Criar Conta",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        onPressed: () => _registrar(context),
      ),
    );
  }

  SizedBox buttonEntrar(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: OutlinedButton(
        onPressed: () => _login(context),
        child: const Text(
          "Entrar",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  SizedBox buttoBiometria(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _authenticateWithBiometrics(context),
        style: Utils.styleButtonElevated(),
        child: const Text(
          "Biometria",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ShowMessager.show(context, 'Por favor, insira sua senha');
    }
    context.read<AuthController>().login(password);
  }

  void _registrar(BuildContext context) {
    GoRouter.of(context).pushReplacement(RoutesPaths.authRegister);
  }

  Future<void> _authenticateWithBiometrics(BuildContext context) async {
    //  try {
    return context.read<AuthController>().loginWithBiometrics();
  }
}

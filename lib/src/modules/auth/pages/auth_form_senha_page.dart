// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/form_field_input_password.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';

class AuthFormSenhaPage extends StatefulWidget {
  const AuthFormSenhaPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthFormSenhaPage> {
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
        body: SafeArea(child: _body(context)));
  }

  _body(BuildContext context) {
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
              SizedBox(height: size.height * .1),
              buttonEsqueciSenha(size, context),
              SizedBox(height: size.height * .1),
            ],
          ),
        ),
      ),
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
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        icon: const Icon(
          Icons.login,
          size: 30,
          color: Colors.white,
        ),
        onPressed: () => _login(context),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ShowMessager.show(context, 'Por favor, insira sua senha');
    }
    await context.read<AuthController>().login(password);

    GoRouter.of(context).push(RoutesPaths.authValidade);

    return;
  }
}

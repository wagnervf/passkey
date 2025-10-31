// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/utils/utils.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
   //   _authenticateWithBiometrics(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
        ),
        body: SafeArea(child: _bodyPage(context)));
  }

  _bodyPage(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: size.height * .05),
          Text(
            'Bem-vindo ao Keezy!',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Text(
              "Armazenamento criptografado e acesso fácil quando precisar",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.all(2.0),
            height: size.height * .15,
            child: Image.asset(
              'assets/images/passkey.png',
              fit: BoxFit.scaleDown,
              color: Colors.teal,
            ),
          ),
          
          SizedBox(height: size.height * .2),
         // buttoBiometria(context),
          SizedBox(height: 20),
          buttonSenha(context),
          SizedBox(height: size.height * .1),
          buttonCriarConta(context),
        ],
      ),
    );
  }

  buttonCriarConta(BuildContext context) {
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

  SizedBox buttonSenha(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: TextButton(
        child: Text(
          "Digite sua Senha Mestra",
        ),
        onPressed: () => GoRouter.of(context).push(RoutesPaths.digitarSenha),
      ),
    );
  }

   void _registrar(BuildContext context) {
    GoRouter.of(context).pushReplacement(RoutesPaths.authRegister);
  }

  // SizedBox buttoBiometria(BuildContext context) {
  //   return SizedBox(
  //     width: MediaQuery.of(context).size.width * .9,
  //     height: 50,
  //     child: ElevatedButton(
  //       onPressed: () => _authenticateWithBiometrics(context),
  //       style: Utils.styleButtonElevated(),
  //       child: const Text(
  //         "Acessar",
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //       ),
  //     ),
  //   );
  // }

 

  // Future<void> _authenticateWithBiometrics(BuildContext context) async {
  //   final result = await context.read<AuthController>().loginWithBiometrics();

  //   if (result) {
  //     GoRouter.of(context).push(RoutesPaths.authValidade);
  //     return;
  //   } else {
  //     ShowMessager.show(
  //       context,
  //       "A autenticação biométrica falhou. Por favor, digite sua senha mestra.",
  //     );
  //     GoRouter.of(context).push(RoutesPaths.digitarSenha);
  //   }
  //   log("Autenticando com biometria: ${result.toString()}");
  //   return;
  // }
}

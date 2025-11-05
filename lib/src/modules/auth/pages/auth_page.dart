// // ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   AuthPageState createState() => AuthPageState();
// }

// class AuthPageState extends State<AuthPage> {
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(const Duration(milliseconds: 300), () {
//       _authenticateWithBiometrics(context);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(toolbarHeight: 10),
//       body: SafeArea(child: _bodyPage(context)),
//     );
//   }

//   SingleChildScrollView _bodyPage(BuildContext context) {
//     Size size = MediaQuery.of(context).size;

//     return SingleChildScrollView(
//       controller: ScrollController(),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(height: size.height * .05),
//           Text(
//             'Bem-vindo ao Keezy!',
//             style: Theme.of(context).textTheme.titleLarge,
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.all(28.0),
//             child: Text(
//               "Armazenamento criptografado e acesso fácil quando precisar",
//               textAlign: TextAlign.center,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(4.0),
//             margin: const EdgeInsets.all(2.0),
//             height: size.height * .15,
//             child: Image.asset(
//               'assets/images/passkey.png',
//               fit: BoxFit.scaleDown,
//               color: Colors.teal,
//             ),
//           ),

//           SizedBox(height: size.height * .2),
//           buttoBiometria(context),
//           SizedBox(height: 20),
//           buttonSenha(context),
//           SizedBox(height: size.height * .1),
//           buttonCriarConta(context),
//         ],
//       ),
//     );
//   }

//   SizedBox buttonCriarConta(BuildContext context) {
//     return SizedBox(
//       child: TextButton(
//         child: Text(
//           "Criar Conta",
//           style: Theme.of(context).textTheme.displaySmall,
//         ),
//         onPressed: () => _registrar(context),
//       ),
//     );
//   }

//   SizedBox buttonSenha(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width * .9,
//       height: 50,
//       child: TextButton(
//         child: Text("Digite sua Senha Mestra"),
//         onPressed: () => GoRouter.of(context).push(RoutesPaths.digitarSenha),
//       ),
//     );
//   }

//   void _registrar(BuildContext context) {
//     GoRouter.of(context).pushReplacement(RoutesPaths.authRegister);
//   }

//   SizedBox buttoBiometria(BuildContext context) {
//     return SizedBox(
//       width: MediaQuery.of(context).size.width * .9,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: () => _authenticateWithBiometrics(context),
//         style: Utils.styleButtonElevated(),
//         child: const Text(
//           "Acessar",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//       ),
//     );
//   }

//   Future<void> _authenticateWithBiometrics(BuildContext context) async {
//     try {
//       final authController = context.read<AuthController>();

//       final bool result = await authController.loginWithBiometrics();

//       log("Resultado da autenticação biométrica: $result");

//       if (result) {
//         GoRouter.of(context).push(RoutesPaths.authValidade);
//       } else {
//         ShowMessager.show(
//           context,
//           "A autenticação biométrica falhou. Por favor, digite sua senha mestra.",
//         );
//         GoRouter.of(context).push(RoutesPaths.digitarSenha);
//       }
//     } catch (e, s) {
//       log('Erro ao tentar autenticar com biometria: $e\n$s');
//       ShowMessager.show(
//         context,
//         "Ocorreu um erro ao tentar autenticar. Tente novamente.",
//       );
//       GoRouter.of(context).push(RoutesPaths.digitarSenha);
//     }
//   }
// }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isBiometricEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricPreference();
  }

  /// Verifica se a biometria foi habilitada anteriormente
  Future<void> _checkBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('biometric_enabled') ?? false;

    setState(() {
      _isBiometricEnabled = enabled;
      _isLoading = false;
    });

    // Se biometria estiver habilitada, tenta autenticar automaticamente
    if (enabled) {
      _authenticateWithBiometrics(context);
    } else {
      GoRouter.of(context).pushReplacement(RoutesPaths.digitarSenha);
    }
  }

  /// Realiza autenticação biométrica
  Future<void> _authenticateWithBiometrics(BuildContext context) async {
    try {
      final result = await context.read<AuthController>().loginWithBiometrics();

      if (result) {
        GoRouter.of(context).pushReplacement(RoutesPaths.authValidade);
      } else {
        ShowMessager.show(
          context,
          "A autenticação biométrica falhou. Por favor, digite sua senha mestra.",
        );
        GoRouter.of(context).pushReplacement(RoutesPaths.digitarSenha);
      }

      log("Autenticando com biometria: $result");
    } catch (e) {
      log('Erro ao autenticar com biometria: $e');
      GoRouter.of(context).pushReplacement(RoutesPaths.digitarSenha);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Enquanto carrega/verifica a biometria, exibe transição neutra
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Verificando autenticação...'),

            Container(
              padding: const EdgeInsets.all(4.0),
              margin: const EdgeInsets.all(2.0),
              height: MediaQuery.of(context).size.height * .15,
              child: Image.asset(
                'assets/images/passkey.png',
                fit: BoxFit.scaleDown,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

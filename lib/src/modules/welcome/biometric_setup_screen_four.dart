// biometric_setup_screen.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart'; // Specific for Android prompts
import 'package:local_auth_darwin/local_auth_darwin.dart';

class BiometricSetupScreenFour extends StatefulWidget {
  const BiometricSetupScreenFour({super.key});

  @override
  State<BiometricSetupScreenFour> createState() =>
      _BiometricSetupScreenFourState();
}

class _BiometricSetupScreenFourState extends State<BiometricSetupScreenFour> {
  final LocalAuthentication auth = LocalAuthentication();

  bool _canCheckBiometrics = false;

  List<BiometricType> _availableBiometrics = [];

  String _authStatus = '';

  @override
  void initState() {
    super.initState();
    _checkBiometrics(); // Check availability on screen load
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on Exception catch (e) {
      canCheckBiometrics = false;
      log("Error checking biometrics: $e");
    }

    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on Exception catch (e) {
      availableBiometrics = <BiometricType>[];
      log("Error getting available biometrics: $e");
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      _availableBiometrics = availableBiometrics;
    });
  }

  // Future<void> _authenticateWithBiometrics() async {
  //   bool authenticated = false;
  //   try {
  //     setState(() {
  //       _authStatus = 'Autenticando...';
  //     });
  //     authenticated = await auth.authenticate(
  //       localizedReason:
  //           'Por favor, autentique para ativar o acesso biométrico ao Cofre',
  //       options: const AuthenticationOptions(
  //         stickyAuth:
  //             true, // Remain authenticated until user explicitly cancels or succeeds
  //         biometricOnly: true, // Only allow biometrics, no device PIN fallback
  //       ),
  //       authMessages: const <AuthMessages>[
  //         AndroidAuthMessages(
  //           signInTitle: 'Autenticação Requerida',
  //           cancelButton: 'Cancelar',
  //           biometricHint: 'Toque no sensor para autenticar',
  //           biometricNotRecognized:
  //               'Biometria não reconhecida. Tente novamente.',
  //           biometricSuccess: 'Autenticado com sucesso!',
  //         ),
  //         IOSAuthMessages(
  //           cancelButton: 'Cancelar',
  //           goToSettingsButton: 'Configurações',
  //           goToSettingsDescription:
  //               'Habilite a biometria para usar esta funcionalidade.',
  //           lockOut: 'Biometria desabilitada. Tente novamente mais tarde.',
  //         ),
  //       ],
  //     );
  //   } on Exception catch (e) {
  //     log("Authentication error: $e");
  //     setState(() {
  //       _authStatus = 'Erro na autenticação: $e';
  //     });
  //     return;
  //   }

  //   if (!mounted) {
  //     return;
  //   }

  //   if (authenticated) {
  //     setState(() {
  //       _authStatus = 'Autenticação bem-sucedida!';
  //     });
  //     log('Biometria ativada com sucesso!');
  //     context.go('/finalization'); // Navigate to finalization screen
  //   } else {
  //     setState(() {
  //       _authStatus = 'Autenticação falhou ou cancelada.';
  //     });
  //     log('Autenticação biométrica falhou ou foi cancelada.');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar Biometria'),
        centerTitle: true,
       
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.fingerprint, // Or Icons.face_id
                    size: 100,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 32),
                  Text(
                    'Deseja ativar o acesso por biometria?',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Use sua impressão digital ou reconhecimento facial para um acesso rápido e seguro ao cofre.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Display availability status
                  // if (_canCheckBiometrics)
                  //   Text(
                  //     'Biometria disponível: ${_availableBiometrics.map((e) => e.toString().split('.').last).join(', ')}',
                  //     style: TextStyle(fontSize: 16, color: Colors.green),
                  //     textAlign: TextAlign.center,
                  //   ),
                  if (!_canCheckBiometrics)
                    Text(
                      'Biometria não disponível ou configurada neste dispositivo.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: 20),
                  // Display authentication status
                  Text(
                    _authStatus,
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _canCheckBiometrics
                        ? () {} // => _authenticateWithBiometrics()
                        : null, // Disable button if biometrics are not available
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Ativar Agora',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      // User skips biometric setup
                      context.go('/finalization'); // Navigate to finalization
                    },
                    child: Text(
                      'Pular',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
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

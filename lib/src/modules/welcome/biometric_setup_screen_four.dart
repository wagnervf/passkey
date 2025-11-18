
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricSetupScreenFour extends StatefulWidget {
  const BiometricSetupScreenFour({super.key});

  @override
  State<BiometricSetupScreenFour> createState() => _BiometricSetupScreenFourState();
}

class _BiometricSetupScreenFourState extends State<BiometricSetupScreenFour> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();

      if (!mounted) return;
      setState(() {
        _canCheckBiometrics = canCheck;
        _availableBiometrics = available;
      });
    } catch (e) {
      log("Erro ao verificar biometria: $e");
      setState(() => _canCheckBiometrics = false);
    }
  }

  Future<void> _activateBiometrics() async {
    setState(() => _isProcessing = true);
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Use sua biometria para ativar o acesso rápido e seguro.',
          biometricOnly: true,
      );

      if (isAuthenticated) {
        await _saveBiometricPreference(true);
        if (!mounted) return;
        _showSnackBar(context, 'Acesso biométrico ativado com sucesso!');
        GoRouter.of(context).go('/home');
      } else {
        _showSnackBar(context, 'Autenticação cancelada.');
      }
    } catch (e) {
      log('Erro ao ativar biometria: $e');
      _showSnackBar(context, 'Erro ao ativar biometria. Tente novamente.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _skipBiometricSetup() async {
    await _saveBiometricPreference(false);
    GoRouter.of(context).go('/home');
  }

  Future<void> _saveBiometricPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enabled);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Biometria'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint,
                    size: 120, color: theme.colorScheme.primary),
                const SizedBox(height: 32),
                Text(
                  'Deseja ativar o acesso por biometria?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Use sua impressão digital ou reconhecimento facial para acessar seu cofre com mais rapidez e segurança.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_canCheckBiometrics)
                  Text(
                    'Disponível: ${_availableBiometrics.map((e) => e.toString().split('.').last).join(', ')}',
                    style: const TextStyle(color: Colors.green, fontSize: 15),
                  )
                else
                  Text(
                    'Biometria não disponível neste dispositivo.',
                    style: const TextStyle(color: Colors.red, fontSize: 15),
                  ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isProcessing ? 'Ativando...' : 'Ativar Agora',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  onPressed:
                      _canCheckBiometrics && !_isProcessing ? _activateBiometrics : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _skipBiometricSetup,
                  child: const Text(
                    'Pular por enquanto',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricSwitchWidget extends StatefulWidget {
  const BiometricSwitchWidget({super.key});

  @override
  State<BiometricSwitchWidget> createState() => _BiometricSwitchWidgetState();
}

class _BiometricSwitchWidgetState extends State<BiometricSwitchWidget> {
  bool _biometricEnabled = false;
  bool _loading = true;
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool('biometric_enabled') ?? false;
    setState(() {
      _biometricEnabled = value;
      _loading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        _showSnackBar('Biometria não disponível neste dispositivo.');
        return;
      }

      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Use sua biometria para ativar o acesso seguro.',
        biometricOnly: true,
      );

      if (!isAuthenticated) {
        _showSnackBar('Autenticação cancelada.');
        return;
      }

      await prefs.setBool('biometric_enabled', true);
      _showSnackBar('Acesso biométrico ativado.');
    } else {
      await prefs.setBool('biometric_enabled', false);
      _showSnackBar('Acesso biométrico desativado.');
    }

    setState(() => _biometricEnabled = value);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SwitchListTile(
      title: Text(
        'Acesso por Biometria',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        'Permitir login com a digital.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      value: _biometricEnabled,
      onChanged: (value) => _toggleBiometric(value),
      activeThumbColor: Theme.of(context).colorScheme.primary,
    
      secondary: Icon(
        _biometricEnabled ? Icons.fingerprint : Icons.do_disturb,
      ),
    );
  }
}

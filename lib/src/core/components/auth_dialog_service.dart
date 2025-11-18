import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';



class AuthDialogService {
  static Future<bool> confirmarAcao({
    required BuildContext context,
    required String titulo,
    required String mensagem,
    String textoCancelar = 'Cancelar',
    String textoConfirmar = 'Confirmar',
    bool exigirBiometria = true,
  }) async {
    // 1. Autenticação biométrica (opcional)
    if (exigirBiometria) {
      final localAuth = LocalAuthentication();
      final isAuthenticated = await localAuth.authenticate(
        localizedReason: "Confirme sua identidade",
        biometricOnly: false,
         authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Autenticação Requerida',
            cancelButton: 'Cancelar',
            signInHint: 'Toque no sensor para autenticar',

          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            localizedFallbackTitle:
                'Habilite a biometria para usar esta funcionalidade.',
          ),
        ],
      );

      if (!isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(

            content: Text("Autenticação necessária.")),
        );
        return false;
      }
    }

    // 2. Caixa de diálogo
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        titleTextStyle: Theme.of(context).textTheme.titleMedium,
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(textoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(textoConfirmar),
          ),
        ],
      ),
    );

    return confirmar ?? false;
  }
}

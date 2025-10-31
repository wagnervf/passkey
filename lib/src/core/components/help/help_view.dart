import 'package:flutter/material.dart';

class HelpView {
  static void mostrarDialogCriarConta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Criar Conta"),
          content: const Text(
              "Criar uma conta exclusiva para acessar o aplicativo garante que apenas você tenha controle total sobre suas senhas e registros. Diferente de logins com Google ou outras contas compartilhadas, onde qualquer pessoa com acesso ao seu celular poderia abrir o app automaticamente, uma conta protegida por uma senha mestra única impede acessos não autorizados. Dessa forma, mesmo que alguém tenha seu dispositivo em mãos, suas informações permanecerão seguras. 🚀🔒"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendi"),
            ),
          ],
        );
      },
    );
  }
}

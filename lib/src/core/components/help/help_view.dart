import 'package:flutter/material.dart';

class HelpView {
  static void mostrarDialogCriarConta(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Senha mestra'),
          content: const Text(
              'A senha mestra protege a chave do cofre neste dispositivo. '
              'Você precisará dela para abrir seus registros. O Keezy não '
              'sincroniza automaticamente com contas ou serviços na nuvem.'),
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

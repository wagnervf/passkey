import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasswordFieldWithGenerator extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int minLength;
  final int maxLength;
  final Function(String)? onChanged;

  const PasswordFieldWithGenerator({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.minLength = 6,
    this.maxLength = 10,
    this.onChanged,
  });

  @override
  State<PasswordFieldWithGenerator> createState() =>
      _PasswordFieldWithGeneratorState();
}

class _PasswordFieldWithGeneratorState
    extends State<PasswordFieldWithGenerator> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  void _copyToClipboard() {
    if (widget.controller.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: widget.controller.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Senha copiada para a área de transferência'),
      ),
    );
  }

  void _generatePassword() {
    final newPassword = _generateSecurePassword(length: widget.maxLength);
    widget.controller.text = newPassword;
    widget.onChanged?.call(newPassword);
  }

  String _generateSecurePassword({int length = 12}) {
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const nums = '0123456789';
    const symbols = '!@#\$%&()=+[]{}|?';
    final all = lower + upper + nums + symbols;

    final rand = Random.secure();
    return List.generate(length, (_) => all[rand.nextInt(all.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Digite sua senha',
            counterText: '',
            suffixIcon: SizedBox(
              width: 136,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'Copiar senha',
                    onPressed: _copyToClipboard,
                  ),
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    tooltip: _obscureText ? 'Mostrar senha' : 'Ocultar senha',
                    onPressed: _toggleVisibility,
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              label: const Text('Gerar Senha'),
              icon: const Icon(Icons.autorenew_rounded),
              onPressed: _generatePassword,
            ),
          ],
        ),
      ],
    );
  }
}

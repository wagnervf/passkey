import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keezy/src/core/utils/secure_password_generator.dart';

class PasswordGeneratorButton extends StatelessWidget {
  const PasswordGeneratorButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.autorenew_rounded),
    label: const Text('Gerar Senha'),
  );
}

class PasswordFieldWithGenerator extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int generatedLength;
  final Function(String)? onChanged;

  const PasswordFieldWithGenerator({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.generatedLength = 16,
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
    final newPassword = generateSecurePassword(length: widget.generatedLength);
    widget.controller.text = newPassword;
    widget.onChanged?.call(newPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            labelText: widget.labelText,
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
          children: [PasswordGeneratorButton(onPressed: _generatePassword)],
        ),
      ],
    );
  }
}

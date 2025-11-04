// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

class ButtonCopiar extends StatelessWidget {
  const ButtonCopiar({
    super.key,
    required TextEditingController controller,
    required this.context,
    required this.message
  }) : _controller = controller;

  final TextEditingController _controller;
  final BuildContext context;
  final String message;


  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.copy),
      tooltip: 'Copiar',
      onPressed: () {
        final text = _controller.text;
        if (text.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(message),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }
}

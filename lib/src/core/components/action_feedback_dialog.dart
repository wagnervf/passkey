import 'package:flutter/material.dart';

class ActionFeedbackDialog extends StatefulWidget {
  final Future<void> Function() action;
  final String successMessage;
  final String loadingMessage;

  const ActionFeedbackDialog({
    super.key,
    required this.action,
    required this.successMessage,
    this.loadingMessage = 'Salvando...',
  });

  @override
  State<ActionFeedbackDialog> createState() => _ActionFeedbackDialogState();
}

class _ActionFeedbackDialogState extends State<ActionFeedbackDialog> {
  bool _isLoading = true;
  String _displayMessage = '';

  @override
  void initState() {
    super.initState();
    _startAction();
  }

  Future<void> _startAction() async {
    setState(() {
      _displayMessage = widget.loadingMessage;
    });

    try {
      await widget.action();
      setState(() {
        _isLoading = false;
        _displayMessage = widget.successMessage;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(true); // Retorna true para sucesso
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _displayMessage = 'Ocorreu um erro. Tente novamente.';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop(false); // Retorna false para erro
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.check_circle, color: Colors.teal, size: 48),
            const SizedBox(height: 20),
            Text(
              _displayMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

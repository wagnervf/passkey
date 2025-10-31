import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keezy/src/core/components/action_type.dart'; // Para HapticFeedback

Future<void> showConfirmActionBottomSheet({
  required BuildContext context,
  required String title,
  required String description,
  required Future<void> Function() onConfirm,
  required ActionType actionType,
}) {
  HapticFeedback.mediumImpact(); // Vibração ao abrir

  return showModalBottomSheet(
    context: context,
    isDismissible: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ConfirmButton(
                    onConfirm: onConfirm,
                    actionType: actionType,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _ConfirmButton extends StatefulWidget {
  final Future<void> Function() onConfirm;
  final ActionType actionType;

  const _ConfirmButton({
    required this.onConfirm,
    required this.actionType,
  });

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton> {
  bool _isLoading = false;

  Color _getColor() {
    switch (widget.actionType) {
      case ActionType.salvar:
        return Colors.teal;
      case ActionType.editar:
        return Colors.blue;
      case ActionType.excluir:
        return Colors.red;
    }
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onConfirm();
      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        Navigator.of(context).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleConfirm,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getColor(),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text('Confirmar'),
    );
  }
}

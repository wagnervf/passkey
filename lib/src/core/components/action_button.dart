import 'package:flutter/material.dart';
import 'package:keezy/src/core/components/action_type.dart';

//enum ActionType { salvar, editar, excluir }

class ActionButton extends StatefulWidget {
  final Future<bool> Function() onPressed;
  final ActionType actionType;
  final String title;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.actionType,
    required this.title,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _loading = false;

  Color _getColor() {
    switch (widget.actionType) {
      case ActionType.salvar:
        return Colors.teal;
      case ActionType.editar:
        return const Color.fromRGBO(255, 160, 0, 1);
      case ActionType.excluir:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (widget.actionType) {
      case ActionType.salvar:
        return Icons.save;
      case ActionType.editar:
        return Icons.edit;
      case ActionType.excluir:
        return Icons.delete;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getColor(),
        minimumSize: const Size(double.infinity, 48),
        side:  BorderSide(
          color: _getColor(),
        ),
      ),
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(_getIcon()),
      label: Text(_loading ? 'Aguarde...' : widget.title),
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              
              final result = await widget.onPressed();

              if (mounted) {
                setState(() => _loading = false);
              }
            },
    );
  }
}

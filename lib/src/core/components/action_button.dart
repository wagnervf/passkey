import 'package:flutter/material.dart';
import 'package:keezy/src/core/components/action_type.dart';

//enum Action { salvar, editar, excluir }

class ActionButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String title;
  final ActionType type;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.title,
    required this.type,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isLoading = false;

  Color _getColor() {
    switch (widget.type) {
      case ActionType.salvar:
        return Colors.teal;
      case ActionType.editar:
        return Colors.blue;
      case ActionType.excluir:
        return Colors.red;
    }
  }

  Future<void> _handlePressed() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.onPressed();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.title} realizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ${widget.title.toLowerCase()}!')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _getColor(),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _isLoading ? null : _handlePressed,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(widget.title),
    );
  }
}

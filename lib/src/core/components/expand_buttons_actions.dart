import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
import 'package:provider/provider.dart';

class ExpandButtonsActions extends StatefulWidget {
  const ExpandButtonsActions({
    super.key,
    required this.registro,
  });

  final RegisterModel registro;

  @override
  State<ExpandButtonsActions> createState() => _ExpandButtonsActionsState();
}

class _ExpandButtonsActionsState extends State<ExpandButtonsActions> {
  final _key = GlobalKey<ExpandableFabState>();

  _compartilharRegistro() async {
    await context
        .read<RegisterController>()
        .exportarUmRegistro(widget.registro);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro compartilhado com sucesso!')),
    );
  }

  _goToEdit() async {
    await GoRouter.of(context)
        .push(RoutesPaths.register, extra: widget.registro);
  }

  Future<void> _excluirRegistro() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir este registro?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                bool result = true;

                result = await context
                    .read<RegisterController>()
                    .deleteRegisterController(widget.registro);

                if (result == true) {
                  ShowMessager.show(context, 'Registro removido');
                }
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: _key,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      // overlayStyle: ExpandableFabOverlayStyle(
      //   color: Colors.white.withOpacity(0.9),
      // ),
      children: [
        Row(
          children: [
            const Text('Compartilhar'),
            const SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _compartilharRegistro(),
              child: const Icon(Icons.share),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Excluir'),
            const SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _excluirRegistro(),
              child: const Icon(Icons.delete),
            ),
          ],
        ),
        const Row(
          children: [
            Text('Favorito'),
            SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: null,
              child: Icon(Icons.favorite),
            ),
          ],
        ),
        Row(
          children: [
            const Text('Alterar'),
            const SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _goToEdit(),
              child: const Icon(Icons.edit),
            ),
          ],
        ),
      ],
    );
  }
}

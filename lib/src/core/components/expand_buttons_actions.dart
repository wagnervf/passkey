import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
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
    final exportarImportarService =
        Provider.of<BackupRestoreController>(context, listen: false);

    exportarImportarService.exportarUmRegistro(widget.registro);

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

                if (context.mounted) {
                  if (result == true) {
                    ShowMessager.show(context, 'Registro removido');
                  }
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
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
    final tema = Theme.of(context).textTheme;
    return ExpandableFab(
      key: _key,
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      children: [
        Row(
          children: [
             Text('Compartilhar', style: tema.labelMedium,),
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
             Text('Excluir', style: tema.labelMedium,),
            const SizedBox(width: 20),
            FloatingActionButton.small(
              heroTag: null,
              onPressed: () => _excluirRegistro(),
              child: const Icon(Icons.delete),
            ),
          ],
        ),
         Row(
          children: [
            Text('Favorito', style: tema.labelMedium,),
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
             Text('Alterar', style: tema.labelMedium,),
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

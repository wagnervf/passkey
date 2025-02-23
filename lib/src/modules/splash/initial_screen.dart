import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/modules/configuracoes/backup_restore/controllers/backup_restore_controller.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exportarImportarService =
        Provider.of<BackupRestoreController>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem Ilustrativa
            SizedBox(
              height: 250,
              child: SvgPicture.asset(
                'assets/images/mobile_encryption.svg', // Caminho da imagem SVG
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 60),
            Text(
              "Gerencie suas senhas com segurança",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),

            const SizedBox(height: 10),
            Text(
              "Armazenamento criptografado e acesso fácil quando precisar",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 80),

            buttonCriarConta(context),
            const SizedBox(height: 20),

            restoredBackup(context, exportarImportarService),
          ],
        ),
      ),
    );
  }

  SizedBox buttonCriarConta(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _registrar(context),
        style: Utils.styleButtonElevated(),
        child: const Text(
          "Criar Conta",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  // void _acessar(BuildContext context) {
  //   GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  // }

  void _registrar(BuildContext context) {
    GoRouter.of(context)
        .pushReplacement(RoutesPaths.authRegister, extra: AuthUserModel());
  }

  SizedBox restoredBackup(BuildContext context,
      BackupRestoreController exportarImportarService) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .9,
      height: 50,
      child: TextButton.icon(
        icon: Icon(Icons.upload_file),
        label: const Text(
          "Restaurar Backup",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: () async {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final authController = context.read<AuthController>();
            final registerController = context.read<RegisterController>();

            final result = await exportarImportarService.restoreBackup(
                authController, registerController);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result != null
                    ? 'Importação concluída!'
                    : 'Erro ao importar os dados.'),
              ),
            );
          });
        },
      ),
    );
  }
}

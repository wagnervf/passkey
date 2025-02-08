import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/item_card_with_icon.dart';
import 'package:passkey/src/core/components/show_messeger.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';
import 'package:passkey/src/modules/configuracoes/views/widgets/icon_change_theme.dart';
import 'package:passkey/src/modules/register/controller/register_controller.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  AuthUserModel? userLoged;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SafeArea(child: body(context)),
    );
  }

  BlocBuilder body(BuildContext context) {
    final int currentYear = DateTime.now().year;
    return BlocBuilder<AuthController, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const CircularProgressIndicator();
        } else if (state is AuthSuccessState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              userLoged = state.user;
            });
          });

          return _body(context, currentYear, userLoged);
        } else if (state is AuthErrorState) {
          return Text('Erro: ${state.message}');
        }
        return const SizedBox.shrink();
      },
    );
  }

  _body(BuildContext context, int currentYear, userLoged) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                         Utils.titleCard(context, 'Gerenciar Tema'),
                          const IconChangeTheme(),
                          const SizedBox(
                            height: 20,
                          ),
                        
                          Utils.titleCard(context, 'Gerenciar Registros'),
                          ItemCardWithIcon(
                              text: 'Exportar Registros',
                              icon: Icons.download,
                              onTap: () => buttonExport(context)),
                          ItemCardWithIcon(
                              text: 'Importar Registros',
                              icon: Icons.upload_file,
                              onTap: () => buttonImport()),
                          const Spacer(),
                          buttonRemoverUser(context),
                          Center(
                            child: Text(
                              '© $currentYear PassKey seu gerenciador de senhas particular e privativo. Todos os direitos reservados.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )),
      );
    });
  }


  InkWell buttonRemoverUser(BuildContext context) {
    return InkWell(
      onTap: () => _confirmarExclusao(context),
      child: Card(
        child: ListTile(
          minTileHeight: 60,
          dense: true,
          contentPadding: const EdgeInsets.only(right: 8, left: 8),
          leading: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          title: Text(
            'Excluir o usuário e apagar os registros',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.red),
          ),
        ),
      ),
    );
  }

  // Modal de confirmação antes de excluir a conta
  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Conta'),
          content: SizedBox(
            height: 180,
            child: Column(
              children: [
                const Text(
                    'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.'),
                Text(
                  'Importante! Realize a exportação dos registros antes de resetar o aplicativo.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                bool result =
                    await context.read<AuthController>().logoutAndRemoveUser();

                if (result) {
                  ShowMessager.show(
                    context,
                    'Usuário removido com sucesso.',
                  );
                  GoRouter.of(context).pushReplacement(RoutesPaths.splash);
                } else {
                  ShowMessager.show(
                    context,
                    'Erro ao tentar remover o usuário. Tente Novamente.',
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  buttonExport(BuildContext context) async {
    bool resultBackup =
        await context.read<RegisterController>().exportarViaArquivo();

    if (resultBackup) {
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('Dados exportados com sucesso!')),
      );
    }
  }

  buttonImport() async {
    bool resultBackup =
        await context.read<RegisterController>().importarViaArquivo();

    if (resultBackup) {
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('Dados importados com sucesso!')),
      );
    }
  }

  profile(BuildContext context, AuthUserModel? userLoged) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.onSecondary,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        leading: CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),
        title: Text(
          userLoged?.name ?? '',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  _auth() {
    return GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  }

  _goToEdit(AuthUserModel userLoged) async {
    await GoRouter.of(context).push(RoutesPaths.authRegister, extra: userLoged);
  }
}

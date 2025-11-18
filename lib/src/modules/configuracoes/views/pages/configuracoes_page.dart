// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/biometric_switch_widget.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/utils/utils.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/configuracoes/views/widgets/icon_change_theme.dart';
import 'package:keezy/src/modules/export_registers_csv/pages/export_exemple_register_widget.dart';
import 'package:keezy/src/modules/export_registers_csv/pages/export_register_csv_page.dart';
import 'package:keezy/src/modules/import_registers_csv/pages/import_register_csv_page.dart';
import 'package:keezy/src/modules/register/controller/register_controller.dart';

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
      appBar: AppBar(title: const Text('Configurações')),
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

  LayoutBuilder _body(BuildContext context, int currentYear, userLoged) {
    return LayoutBuilder(
      builder: (context, constraint) {
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
                          Utils.titleCard(context, 'Opções'),
                          const SizedBox(height: 10),
                          Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                BiometricSwitchWidget(),
                                _divider(),
                                const IconChangeTheme(),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),
                          Utils.titleCard(context, 'Gerenciar Registros'),
                          const SizedBox(height: 10),

                          Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            child: Column(
                              children: [
                                ExportRegisterCsvPage(),
                                _divider(),
                                ImportRegisterCsvPage(),
                                _divider(),
                                ExportExempleRegisterWidget(),
                              ],
                            ),
                          ),

                          const Spacer(),

                          Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              onTap: () => _confirmarExclusao(context),
                              leading: Icon(
                                Icons.dangerous_outlined,
                                color: Colors.red[800],
                              ),
                              title: Text(
                                'Excluir todos os dados',
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(color: Colors.red[800]),
                              ),
                              subtitle: Text(
                                'Apagar do celular todos os dados do aplicativo.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              '© $currentYear keezy seu gerenciador de senhas particular e privativo. Todos os direitos reservados.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Padding _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(thickness: 1),
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
                  'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita.',
                ),
                Text(
                  'Importante! Realize a exportação dos registros antes de resetar o aplicativo.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: Colors.red),
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
                bool result = await context
                    .read<AuthController>()
                    .logoutAndRemoveUser();

                await context
                    .read<RegisterController>()
                    .deleteAllRegistersController();

                if (result) {
                  ShowMessager.show(context, 'Usuário removido com sucesso.');
                } else {
                  ShowMessager.show(
                    context,
                    'Erro ao tentar remover o usuário. Tente Novamente.',
                  );
                }

                GoRouter.of(context).pushReplacement(RoutesPaths.splash);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  ColoredBox profile(BuildContext context, AuthUserModel? userLoged) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.onSecondary,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        leading: CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        title: Text(
          userLoged?.name ?? '',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

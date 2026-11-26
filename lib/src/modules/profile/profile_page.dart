import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/item_card_with_icon.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(child: body(context)),
    );
  }

  BlocBuilder body(BuildContext context) {
    return BlocBuilder<AuthController, AuthState>(
      builder: (context, state) {
        if (state is AuthLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AuthSuccessState) {
          final user = state.user;
          return user == null
              ? const Center(child: Text('Perfil indisponível.'))
              : _body(context, user);
        } else if (state is AuthErrorState) {
          return Center(child: Text('Erro: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _body(BuildContext context, AuthUserModel userLoged) {
    return SingleChildScrollView(
      child: Column(
        children: [
          profile(context, userLoged),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  ItemCardWithIcon(
                    text: 'Editar Perfil',
                    subtTitle: 'Altere os dados do seu perfil',
                    icon: Icons.edit,
                    onTap: () => _goToEdit(userLoged),
                  ),
                  _divider(),
                  ItemCardWithIcon(
                    text: 'Configurações',
                    subtTitle: 'Altere as configurações do app',
                    icon: Icons.settings,
                    onTap: _goToConfig,
                  ),
                  _divider(),
                  ItemCardWithIcon(
                    text: 'Sair',
                    subtTitle: 'Sair do aplicativo',
                    icon: Icons.logout_outlined,
                    onTap: _auth,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Divider(
        thickness: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  ColoredBox profile(BuildContext context, AuthUserModel? userLoged) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
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
        subtitle: Text(
          userLoged?.email ?? '',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }

  Future<void> _auth() async {
    await context.read<AuthController>().lockVault();
    if (mounted) GoRouter.of(context).go(RoutesPaths.digitarSenha);
  }

  Future<void> _goToEdit(AuthUserModel userLoged) async {
    await GoRouter.of(context).push(RoutesPaths.authRegister, extra: userLoged);
  }

  Future<void> _goToConfig() async {
    await GoRouter.of(context).push(RoutesPaths.config);
  }
}

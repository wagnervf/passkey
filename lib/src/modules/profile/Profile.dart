import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/item_card_with_icon.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/core/utils/utils.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        title: const Text('Perfil'),
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
                  profile(context, userLoged),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Utils.titleCard(context, 'Usuário'),
                          ItemCardWithIcon(
                            text: 'Editar Perfil',
                            icon: Icons.edit,
                            onTap: () => _goToEdit(userLoged!),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Utils.titleCard(context, 'Sistema'),
                          ItemCardWithIcon(
                            text: 'Configurações',
                            icon: Icons.settings,
                            onTap: () => _goToConfig(userLoged!),
                          ),
                          const Spacer(),
                          ItemCardWithIcon(
                            text: 'Sair',
                            icon: Icons.logout_outlined,
                            onTap: () => _auth(),
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

  profile(BuildContext context, AuthUserModel? userLoged) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.onTertiary,
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
        subtitle: Text(
          userLoged?.email ?? '',
          style: Theme.of(context).textTheme.titleSmall,
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

  _goToConfig(AuthUserModel userLoged) async {
    await GoRouter.of(context).push(RoutesPaths.config, extra: userLoged);
  }
}

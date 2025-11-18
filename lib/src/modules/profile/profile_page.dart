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
        toolbarHeight: 10,
        excludeHeaderSemantics: true,
        leading: SizedBox.shrink(),
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
                  profile(context, userLoged),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,

                            child: Column(
                              children: [
                                SizedBox(height: 20,),
                                ItemCardWithIcon(
                                  text: 'Editar Perfil',
                                  subtTitle: 'Altere os dados do seu perfil',
                                  icon: Icons.edit,
                                  onTap: () => _goToEdit(userLoged!),
                                ),
                                _divider(),
                                ItemCardWithIcon(
                                  text: 'Configurações',
                                  subtTitle: 'Altere as configurações do app',
                                  icon: Icons.settings,
                                  onTap: () => _goToConfig(userLoged!),
                                ),
                                _divider(),
                                ItemCardWithIcon(
                                  text: 'Sair',
                                  subtTitle: 'Sair do aplicativo',
                                  icon: Icons.logout_outlined,
                                  onTap: () => _auth(),
                                ),
                              ],
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

  Future<Object?> _auth() {
    return GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  }

  Future<void> _goToEdit(AuthUserModel userLoged) async {
    await GoRouter.of(context).push(RoutesPaths.authRegister, extra: userLoged);
  }

  Future<void> _goToConfig(AuthUserModel userLoged) async {
    await GoRouter.of(context).push(RoutesPaths.config, extra: userLoged);
  }
}

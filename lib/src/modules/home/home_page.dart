import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/core/session/session_manager.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/providers/auth_user_provider.dart';
import 'package:keezy/src/modules/register/views/widgets/list_registers.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (SessionManager.isExpired()) {
    GoRouter.of(context).go('/login');
  }
}


  AuthUserModel? user;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      floatingActionButton: buttonAdd(context),
      drawer: const AppDrawer(
      appName: 'Proteja Seus Dados',
      logoPath: 'assets/images/passkey.png',
    ),
      appBar: AppBar(
        excludeHeaderSemantics: true,
        leading: SizedBox.shrink(),
        centerTitle: false,
        titleSpacing: 0,
        elevation: 0,
        leadingWidth: 20,
        title: Consumer<AuthUserProvider>(
          builder: (context, authUserProvider, child) {
            final user = authUserProvider.user;
            if (user == null) {
              return Center(child: Text('No user logged in.'));
            }
            return Text(user.name, style: tema.displayMedium);
          },
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              onPressed: () => _sair(),
              icon: const Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthController, AuthState>(
          builder: (context, state) {
            if (state is AuthLoadingState) {
              return const CircularProgressIndicator();
            } else if (state is AuthSuccessState) {         

              return ListRegisters();
            } else if (state is AuthErrorState) {
              return Text('Erro: ${state.message}');
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Future<Object?> _sair() {
    return GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  }

  FloatingActionButton buttonAdd(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => GoRouter.of(context).push(RoutesPaths.register),
      tooltip: 'Novo Registro',
      child: const Icon(Icons.add),
    );
  }
}




class AppDrawer extends StatelessWidget {
  final String appName;
  final String logoPath;

  const AppDrawer({
    super.key,
    required this.appName,
    required this.logoPath,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Cabeçalho com logo e nome
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    logoPath,
                    width: 56,
                    height: 56,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      appName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Opções do menu
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Configurações'),
              onTap: () {
                GoRouter.of(context).push('/configuracoes');
              },
            ),

            const Divider(),

            // Você pode adicionar mais itens aqui
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda'),
              onTap: () {
                GoRouter.of(context).push('/ajuda');
              },
            ),

            const Spacer(),

            // Botão de sair
            ListTile(
              leading: const Icon(Icons.logout_outlined, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                _confirmLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deseja sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/login');
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}


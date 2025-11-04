import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
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

  AuthUserModel? user;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      floatingActionButton: buttonAdd(context),
      drawer: Drawer(),
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

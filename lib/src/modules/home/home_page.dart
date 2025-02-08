import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/components/drawer_custom.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';
import 'package:passkey/src/modules/register/views/widgets/list_registers.dart';

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
    //final tema = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      drawer: const DrawerCustom(),
      appBar: AppBar(
        title: Text(user?.name.toUpperCase() ?? '',
            style: Theme.of(context).textTheme.displayMedium),
            actions: [
              IconButton(onPressed: () => _goToConfig(), icon: const Icon(Icons.settings)),
              IconButton(onPressed: () => _auth(), icon: const Icon(Icons.logout_outlined))
            ],
      ),
      body: BlocBuilder<AuthController, AuthState>(
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return const CircularProgressIndicator();
          } else if (state is AuthSuccessState) {
           WidgetsBinding.instance.addPostFrameCallback((_) { 
             setState(() {
                user = state.user;
             });
           });

            return const Padding(
              padding: EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: ListRegisters(),
              ),
            );
          } else if (state is AuthErrorState) {
            return Text('Erro: ${state.message}');
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: buttonAdd(context),
    );
  }

  FloatingActionButton buttonAdd(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => GoRouter.of(context).push(RoutesPaths.register),
      tooltip: 'Novo Registro',
      child: const Icon(Icons.add),
    );
  }

   _auth() {
    return GoRouter.of(context).pushReplacement(RoutesPaths.auth);
  }

  

  _goToConfig() async {
    await GoRouter.of(context).push(RoutesPaths.config);
  }
}

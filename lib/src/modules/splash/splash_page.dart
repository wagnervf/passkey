import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/core/router/routes.dart';
import 'package:passkey/src/modules/auth/controllers/auth_controller.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/splash/initial_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  checkAuthentication() async {
    await context.read<AuthController>().checkAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SafeArea(
        child: _blocBuilder(context),
      ),
    );
  }

  BlocBuilder<AuthController, AuthState> _blocBuilder(BuildContext context) {
    return BlocBuilder<AuthController, AuthState>(
      builder: (contx, state) {
        log('SplashPage: $state');
        if (state is AuthLoadingState) {
          return loading();
        } else if (state is AuthUnauthenticatedState) {
          //_notUser(context);
          return InitialScreen();
        } else if (state is AuthSuccessState) {
          _authSucess(context);
          return loading();
        } else {
          _noAuthenticated(context);

          return loading();
        }
      },
    );
  }

  // void _notUser(BuildContext context) {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     GoRouter.of(context).pushReplacement(RoutesPaths.initial);
  //     //.pushReplacement(RoutesPaths.authRegister, extra: AuthUserModel());
  //   });
  // }

  void _noAuthenticated(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).pushReplacement(RoutesPaths.auth);
    });
  }

  void _authSucess(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).pushReplacement(
        RoutesPaths.home,
       // RoutesPaths.listRegisters,
      );
    });
  }

  Center loading() {
    return const Center(
        child: CircularProgressIndicator(
      backgroundColor: Colors.teal,
    ));
  }
}

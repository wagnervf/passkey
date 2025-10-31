// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/components/show_messeger.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';

class AuthValidadePage extends StatefulWidget {
  const AuthValidadePage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthValidadePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthController, AuthState>(
          listener: (context, state) {
            log("AuthValidadePage - state: $state");
            if (state is AuthSuccessState) {
              GoRouter.of(context).pushReplacement(
                RoutesPaths.home,
                extra: state.user,
              );
              return;
            } else if (state is AuthErrorState) {
              ShowMessager.show(
                context,
                state.message,
              );
            }
          },
          builder: (context, state) {
            log("AuthValidadePage 2 - state: $state");
            if (state is AuthLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AuthSuccessState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GoRouter.of(context).pushReplacement(
                  RoutesPaths.home,
                  extra: state.user,
                );
              });
            }

            if (state is AuthErrorState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ShowMessager.show(
                  context,
                  state.message,
                );
                GoRouter.of(context).pop();
              });
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

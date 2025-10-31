import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:keezy/src/core/router/routes.dart';
import 'package:keezy/src/modules/auth/controllers/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
     _checkHasUser();
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SafeArea(
        child: loading(),
      ),
    );
  }

  Future<void> _checkHasUser() async {
    try {
      final isAuthenticated = await context.read<AuthController>().checkExistUserLocal();
      log('User exists: $isAuthenticated');
      //existe usuário
      if (isAuthenticated) {
        if(!mounted)return;        
        return _hasUser(context);
      } else {
        if(!mounted)return;        
        return _hasNotUser(context);
      }
    } catch (e) {
      log('Error during authentication: $e');
      return;
     // GoRouter.of(context).pushReplacement(RoutesPaths.auth);
    }
  }

 
// BlocConsumer<AuthController, AuthState> _blocCosumer() {
//     return BlocConsumer<AuthController, AuthState>(
//       listener: (context, state) {
//         // if (state is AuthSuccessState) {
//         //  _authSucess(context);
//         //   return;
//         // }
//       },
//       builder: (context, state) {
//          if (state is AuthLoadingState) {
//           return loading();
//         }  else if (state is AuthUnauthenticatedState) {
//           unautheticated(context);
//           return const SizedBox.shrink();
//         } else {
//           _noAuthenticated(context);
//           return loading();
//         }
//       },
//     );
//   }

  void _hasNotUser(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).pushReplacement(RoutesPaths.initial);
    });
  }

  void _hasUser(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context).pushReplacement(RoutesPaths.auth);
    });
  }

 
  Center loading() {
    return const Center(
        child: CircularProgressIndicator(
      backgroundColor: Colors.teal,
    ));
  }
}

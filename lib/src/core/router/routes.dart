import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passkey/src/modules/auth/pages/auth_page.dart';
import 'package:passkey/src/modules/auth/pages/register_auth_page.dart';
import 'package:passkey/src/modules/splash/initial_screen.dart';
import 'package:passkey/src/modules/splash/splash_page.dart';
import 'package:passkey/src/modules/configuracoes/views/pages/configuracoes_page.dart';
import 'package:passkey/src/modules/home/home_navigation_page.dart';
import 'package:passkey/src/modules/profile/Profile.dart';
import 'package:passkey/src/modules/register/forms/credit_card_form.dart';
import 'package:passkey/src/modules/register/views/pages/register_form.dart';
import 'package:passkey/src/modules/register/views/pages/register_view.dart';

part 'routes_pages.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String initial = RoutesPaths.splash;

final routes = GoRouter(
  initialLocation: initial,
  navigatorKey: navigatorKey,
  routes: <RouteBase>[

    // GoRoute(
    //   path: RoutesPaths.initial,
    //   name: 'Initial Screen',
    //   parentNavigatorKey: navigatorKey,
    //   builder: (context, state) {
    //     return const InitialScreen();
    //   },
    // ),

    GoRoute(
      path: RoutesPaths.splash,
      name: 'Inicio',
      parentNavigatorKey: navigatorKey,
      builder: (context, state) {
        return const SplashPage();
      },
    ),

    GoRoute(
      path: RoutesPaths.auth,
      name: 'Auth',
      parentNavigatorKey: navigatorKey,
      builder: (context, state) => const AuthPage(),
    ),
    
     GoRoute(
      path: RoutesPaths.authRegister,
      name: 'Auth Register',
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child:  const RegisterAuthPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RoutesPaths.home,
      name: 'Home',
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const HomeNavigationPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RoutesPaths.profile,
      name: 'Profile',
      parentNavigatorKey: navigatorKey,
      builder: (context, state) {
        return const ProfilePage();
      },
    ),
    GoRoute(
      path: RoutesPaths.register,
      name: 'Register',
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const RegisterForm(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RoutesPaths.registerView,
      name: 'Register View',
      parentNavigatorKey: navigatorKey, 

      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child:  const RegisterView(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: RoutesPaths.formCard,
      name: 'Form Card',
      parentNavigatorKey: navigatorKey,
      builder: (context, state) {
        return const CreditCardForm();
      },
    ),
    GoRoute(
      path: RoutesPaths.config,
      name: 'Configurações',
      parentNavigatorKey: navigatorKey,
      builder: (context, state) {
        return  ConfiguracoesPage();
      },
    ),
  ],
);

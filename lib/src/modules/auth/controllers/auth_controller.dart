import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/storage/i_token_storage.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/providers/auth_user_provider.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({
    required this.tokenStorage,
    required this.authRepository,
  }) : super(AuthInitialState());

  final TokenStorageInterface tokenStorage;
  final AuthRepository authRepository;

  AuthUserModel? _user;
  AuthUserModel? get userLogado => _user;

  Future<void> checkAuthentication() async {
    emit(AuthLoadingState());
    _user = await authRepository.getUser();

    if (_user != null) {
      emit(AuthSuccessState(_user));
      AuthUserProvider.instance.setUser(_user!);
      return;
    } else {
      emit(AuthErrorState('Usuário não encontrado!'));
      emit(AuthUnauthenticatedState());
      return;
    }
  }

  Future<bool> login(String password) async {
    emit(AuthLoadingState());
    final isValid = await authRepository.validatePassword(password);

    if (isValid) {
      try {
        final user = await authRepository.getUser();

        emit(AuthSuccessState(user!));
        // Notify the provider about the new user
        AuthUserProvider.instance.setUser(user);
        return true;
      } catch (e) {
        emit(AuthErrorState('Usuário não encontrado!'));
        return false;
      }
    } else {
      emit(AuthErrorState('Senha incorreta'));
      return false;
    }
  }

  Future<void> registerUser(AuthUserModel user) async {
    emit(AuthLoadingState());
    try {
      final result = await authRepository.saveUser(user);
      if (result) {
        emit(AuthSuccessState(user));

        //Para saber que já existe um usuário registrado
        await tokenStorage.saveHasUser(true);
        AuthUserProvider.instance.setUser(user);
      } else {
        await tokenStorage.saveHasUser(false);
        emit(AuthErrorState('Erro ao cadastrar usuário'));
      }
    } catch (e) {
      await tokenStorage.saveHasUser(false);
      emit(AuthErrorState('Erro ao cadastrar usuário'));
    }
  }

  Future<bool> logoutAndRemoveUser() async {
    emit(AuthLoadingState());
    bool result = await authRepository.logoutAndRemoveUser();
     await tokenStorage.saveHasUser(false);

    if (result) {
      emit(AuthUnauthenticatedState());
      return true;
    } else {
      return false;
    }
  }

  Future<void> limparContaAntesDeCriarUser() async {
     await tokenStorage.saveHasUser(false);
    await authRepository.logoutAndRemoveUser();
  }

  Future<bool> loginWithBiometrics() async {
  final localAuth = LocalAuthentication();

  try {
    // Verifica se o dispositivo suporta biometria
    final bool isSupported = await localAuth.isDeviceSupported();
    final bool canCheck = await localAuth.canCheckBiometrics;

    if (!isSupported || !canCheck) {
      emit(AuthErrorState('Biometria não disponível neste dispositivo.'));
      return false;
    }

    // Verifica se há biometria cadastrada
    final availableBiometrics = await localAuth.getAvailableBiometrics();
    if (availableBiometrics.isEmpty) {
      emit(AuthErrorState('Nenhum dado biométrico cadastrado.'));
      return false;
    }

    // Inicia a autenticação biométrica
    final bool isAuthenticated = await localAuth.authenticate(
      localizedReason: 'Use sua biometria para entrar no aplicativo',
        biometricOnly: true,

       
      

      authMessages: const <AuthMessages>[
        
        AndroidAuthMessages(
          signInTitle: 'Autenticação Requerida',
          cancelButton: 'Cancelar',
          signInHint: 'Toque no sensor para autenticar',
          
          //biometricNotRecognized: 'Biometria não reconhecida. Tente novamente.',
          //biometricSuccess: 'Autenticado com sucesso!',
        ),
        IOSAuthMessages(
          cancelButton: 'Cancelar',
          localizedFallbackTitle:
              'Habilite a biometria para usar esta funcionalidade.',
        ),
      ],
      // options: const AuthenticationOptions(
      //   biometricOnly: true,
      //   stickyAuth: true, // mantém autenticação ao trocar de app
      //   useErrorDialogs: true,
      // ),
    );

    if (isAuthenticated) {
      await checkAuthentication();
      return true;
    }

    emit(AuthErrorState('Autenticação cancelada pelo usuário.'));
    return false;

  } on PlatformException catch (e) {
    // Trata erros específicos do sistema
    log('Erro biométrico: ${e.code}');
    emit(AuthErrorState('Erro de autenticação biométrica: ${e.code}'));
    return false;
  } catch (e) {
    log('Erro inesperado ao autenticar: $e');
    emit(AuthErrorState('Erro ao autenticar com biometria. Tente novamente.'));
    return false;
  }
}


  // Future<bool> loginWithBiometrics() async {
  //   try {
  //     final LocalAuthentication localAuth = LocalAuthentication();

  //     final isBiometricSupported = await localAuth.canCheckBiometrics;

  //     if (!isBiometricSupported) {
  //       emit(
  //         AuthErrorState('Biometria não disponível neste dispositivo'),
  //       );
  //       return false;
  //     }

  //     final isAuthenticated = await localAuth.authenticate(
  //       localizedReason: 'Use sua biometria para entrar no aplicativo',
  //       authMessages: const <AuthMessages>[
  //         AndroidAuthMessages(
  //           signInTitle: 'Autenticação Requerida',
  //           cancelButton: 'Cancelar',
  //           signInHint: 'Toque no sensor para autenticar',
  //           // biometricNotRecognized:
  //           //     'Biometria não reconhecida. Tente novamente.',
  //           // biometricSuccess: 'Autenticado com sucesso!',
  //         ),
  //         IOSAuthMessages(
  //           cancelButton: 'Cancelar',
  //         //  goToSettingsButton: 'Configurações',
  //           localizedFallbackTitle:
  //               'Habilite a biometria para usar esta funcionalidade.',
  //         //  lockOut: 'Biometria desabilitada. Tente novamente mais tarde.',
  //         ),
  //       ],
  //       // options: const AuthenticationOptions(
  //       //   biometricOnly: true,
  //       // ),
  //     );

  //     if (isAuthenticated) {
  //       await checkAuthentication();
  //       return true;
  //     }

  //     return false;
  //   } catch (e) {
  //     emit(
  //       AuthErrorState('Erro ao autenticar com biometria. Tete Novamente'),
  //     );
  //     return false;
  //   }
  // }


  Future<bool> checkExistUserLocal() async{
    return await tokenStorage.getHasUser();
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:passkey/src/core/storage/i_token_storage.dart';
import 'package:passkey/src/modules/auth/controllers/auth_state.dart';
import 'package:passkey/src/modules/auth/model/auth_user_model.dart';
import 'package:passkey/src/modules/auth/repositories/auth_repository.dart';
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
    } else {
      emit(AuthErrorState('Usuário não encontrado!'));
      emit(AuthUnauthenticatedState());
    }
  }

  Future<void> login(String password) async {
    emit(AuthLoadingState());
    final isValid = await authRepository.validatePassword(password);

    if (isValid) {
      try {
        final user = await authRepository.getUser();

        emit(AuthSuccessState(user!));
      } catch (e) {
        emit(AuthErrorState('Usuário não encontrado!'));
      }
    } else {
      emit(AuthErrorState('Senha incorreta'));
    }
  }

  Future<void> registerUser(AuthUserModel user) async {
    emit(AuthLoadingState());
    try {
      final result = await authRepository.saveUser(user);
      result
          ? emit(AuthSuccessState(user))
          : emit(AuthErrorState('Erro ao cadastrar usuário'));
    } catch (e) {
      emit(AuthErrorState('Erro ao cadastrar usuário'));
    }
  }

  Future<bool> logoutAndRemoveUser() async {
    emit(AuthLoadingState());
    bool result = await authRepository.logoutAndRemoveUser();

    if (result) {
      emit(AuthUnauthenticatedState());
      return true;
    } else {
      return false;
    }
  }

  loginWithBiometrics() async {
    try {
      final LocalAuthentication localAuth = LocalAuthentication();

      final isBiometricSupported = await localAuth.canCheckBiometrics;

      if (!isBiometricSupported) {
        return emit(
            AuthErrorState('Biometria não disponível neste dispositivo'));
      }

      final isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Use sua biometria para entrar no aplicativo',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Autenticação Requerida',
            cancelButton: 'Cancelar',
            biometricHint: 'Toque no sensor para autenticar',
            biometricNotRecognized:
                'Biometria não reconhecida. Tente novamente.',
            biometricSuccess: 'Autenticado com sucesso!',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancelar',
            goToSettingsButton: 'Configurações',
            goToSettingsDescription:
                'Habilite a biometria para usar esta funcionalidade.',
            lockOut: 'Biometria desabilitada. Tente novamente mais tarde.',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        await checkAuthentication();
      }
    } catch (e) {
      return emit(
          AuthErrorState('Erro ao autenticar com biometria. Tete Novamente'));
    }
  }
}

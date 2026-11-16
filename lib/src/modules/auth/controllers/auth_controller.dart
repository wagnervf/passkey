import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/storage/i_token_storage.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:keezy/src/modules/auth/controllers/auth_state.dart';
import 'package:keezy/src/modules/auth/model/auth_user_model.dart';
import 'package:keezy/src/modules/auth/providers/auth_user_provider.dart';
import 'package:keezy/src/modules/auth/repositories/auth_repository.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends Cubit<AuthState> {
  AuthController({required this.tokenStorage, required this.authRepository})
    : super(AuthInitialState());

  final TokenStorageInterface tokenStorage;
  final AuthRepository authRepository;

  AuthUserModel? _user;
  AuthUserModel? get userLogado => _user;

  Future<void> checkAuthentication() async {
    emit(AuthLoadingState());
    if (!RegisterHive.isUnlocked) {
      emit(AuthUnauthenticatedState());
      return;
    }
    _user = await authRepository.getUser();

    if (_user != null) {
      emit(AuthSuccessState(_user));
      AuthUserProvider.instance.setUser(_user!);
      return;
    } else {
      await RegisterHive.lock();
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
        final hadLegacyKey =
            await RegisterHive.keyManager.store.readLegacyKey() != null;
        await RegisterHive.unlockWithPassword(password, createIfMissing: true);
        final prefs = await SharedPreferences.getInstance();
        if (hadLegacyKey && prefs.getBool('biometric_enabled') == true) {
          try {
            await RegisterHive.enableBiometrics();
          } catch (_) {
            await prefs.setBool('biometric_enabled', false);
          }
        }
        final user = await authRepository.getUser();
        if (user == null) {
          await RegisterHive.lock();
          emit(AuthErrorState('Usuário não encontrado!'));
          return false;
        }
        _user = user;
        emit(AuthSuccessState(user));
        // Notify the provider about the new user
        AuthUserProvider.instance.setUser(user);
        return true;
      } catch (_) {
        emit(
          AuthErrorState('Não foi possível abrir o cofre. Tente novamente.'),
        );
        return false;
      }
    } else {
      emit(AuthErrorState('Senha incorreta'));
      return false;
    }
  }

  Future<bool> registerUser(AuthUserModel user) async {
    emit(AuthLoadingState());
    try {
      if (!await authRepository.hasUser()) {
        await RegisterHive.completePendingDeletion();
      }
      final result = await authRepository.saveUser(user);
      if (result) {
        await RegisterHive.unlockWithPassword(
          user.password,
          createIfMissing: true,
        );
        final savedUser = await authRepository.getUser();
        if (savedUser == null) {
          await RegisterHive.lock();
          emit(AuthErrorState('Erro ao cadastrar usuário'));
          return false;
        }
        _user = savedUser;
        emit(AuthSuccessState(savedUser));

        // A credencial persistida é a fonte de verdade; a preferência é legado.
        try {
          await tokenStorage.saveHasUser(true);
        } catch (_) {}
        AuthUserProvider.instance.setUser(savedUser);
        return true;
      } else {
        emit(AuthErrorState('Erro ao cadastrar usuário'));
        return false;
      }
    } catch (_) {
      emit(
        AuthErrorState(
          'Não foi possível preparar o cofre. Tente entrar com sua senha.',
        ),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
  }) async {
    emit(AuthLoadingState());
    final saved = await authRepository.updateProfile(name: name, email: email);
    if (!saved) {
      emit(AuthErrorState('Erro ao atualizar perfil'));
      return false;
    }
    final user = await authRepository.getUser();
    if (user == null) {
      emit(AuthErrorState('Erro ao atualizar perfil'));
      return false;
    }
    _user = user;
    AuthUserProvider.instance.setUser(user);
    emit(AuthSuccessState(user));
    return true;
  }

  Future<bool> logoutAndRemoveUser() async {
    emit(AuthLoadingState());
    try {
      await RegisterHive.markEmptyVaultForDeletion();
      final result = await authRepository.logoutAndRemoveUser();
      if (!result) {
        emit(AuthErrorState('Erro ao remover o usuário'));
        return false;
      }
      await RegisterHive.completePendingDeletion();
      await tokenStorage.saveHasUser(false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', false);
      _user = null;
      AuthUserProvider.instance.clearUser();
      emit(AuthUnauthenticatedState());
      return true;
    } catch (_) {
      emit(AuthErrorState('Erro ao remover o usuário'));
      return false;
    }
  }

  Future<void> lockVault() async {
    await RegisterHive.lock();
    _user = null;
    AuthUserProvider.instance.clearUser();
    emit(AuthUnauthenticatedState());
  }

  Future<bool> loginWithBiometrics() async {
    final localAuth = LocalAuthentication();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('biometric_enabled') != true) {
        emit(AuthErrorState('Biometria não ativada.'));
        return false;
      }
      final hasBoundKey =
          await RegisterHive.keyManager.store.readPasswordEnvelope() != null;
      if (hasBoundKey) {
        await RegisterHive.unlockWithBiometrics();
        await checkAuthentication();
        return RegisterHive.isUnlocked;
      }

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
        await RegisterHive.unlockLegacyAfterBiometrics();
        await checkAuthentication();
        return RegisterHive.isUnlocked;
      }

      emit(AuthErrorState('Autenticação cancelada pelo usuário.'));
      return false;
    } on PlatformException catch (e) {
      // Trata erros específicos do sistema
      log('Erro biométrico: ${e.code}');
      emit(AuthErrorState('Erro de autenticação biométrica: ${e.code}'));
      return false;
    } catch (_) {
      emit(
        AuthErrorState(
          'Não foi possível desbloquear o cofre com biometria. Use a senha mestra.',
        ),
      );
      return false;
    }
  }

  Future<bool> checkExistUserLocal() async {
    final exists = await authRepository.hasUser();
    if (!exists) await RegisterHive.completePendingDeletion();
    return exists;
  }
}

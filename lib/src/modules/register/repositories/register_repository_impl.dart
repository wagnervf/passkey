// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/register/model/registro_model.dart';
import 'package:keezy/src/modules/register/repositories/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  RegisterRepositoryImpl();

  final SecureStorageService _secureStorageService = SecureStorageService();
  static const _keyRegistros = 'registers';

  /// Obtém todos os registros salvos
  Future<List<RegisterModel>> _getListRegister() async {
    try {
      final List<String>? registrosString =
          await _secureStorageService.getStringList(_keyRegistros);

      if (registrosString == null || registrosString.isEmpty) {
        return [];
      }

      return registrosString
          .map(
            (registro) => RegisterModel.fromMap(
              jsonDecode(registro),
            ),
          )
          .toList();
    } catch (e, s) {
      log("Erro ao buscar registros: $e", error: e, stackTrace: s);
      return [];
    }
  }

  /// Salva uma lista de registros no armazenamento seguro
  Future<bool> _salvarLocalmente(List<RegisterModel> listRegisters) async {
    try {
      final List<String> registrosString = listRegisters
          .map(
            (reg) => jsonEncode(
              reg.toMap(),
            ),
          )
          .toList();
      return await _secureStorageService.saveStringList(
          _keyRegistros, registrosString);
    } catch (e, s) {
      log("Erro ao salvar registros localmente: $e", error: e, stackTrace: s);
      return false;
    }
  }

  @override
  Future<Either<RepositoryException, List<RegisterModel>>>
      getAllRegisterRepository() async {
    try {
      final List<RegisterModel> listRegisters = await _getListRegister();
      return Right(listRegisters);
    } catch (e, s) {
      log("Erro ao obter registros: $e", error: e, stackTrace: s);
      return Left(
        RepositoryException(message: 'Erro ao buscar os registros.'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, bool>> saveRegisterRepository(
      RegisterModel register) async {
    try {
      final List<RegisterModel> listRegisters = await _getListRegister();
      listRegisters.add(register);

      final bool result = await _salvarLocalmente(listRegisters);
      return Right(result);
    } catch (e, s) {
      log("Erro ao salvar registro: $e", error: e, stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao salvar o registro.'));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> saveListRegisterRepository(
      List<RegisterModel> listRegisters) async {
    try {
      //final List<RegisterModel> listRegisters = await _getListRegister();
     // listRegisters.add(register);

      final bool result = await _salvarLocalmente(listRegisters);
      return Right(result);
    } catch (e, s) {
      log("Erro ao salvar registro: $e", error: e, stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao salvar o registro.'));
    }
  }


  

  @override
  Future<Either<RepositoryException, bool>> updateRegisterRepository(
      RegisterModel registro) async {
    try {
      final List<RegisterModel> listRegisters = await _getListRegister();
      final int index =
          listRegisters.indexWhere((reg) => reg.id == registro.id);

      if (index == -1) {
        return Left(RepositoryException(message: 'Registro não encontrado.'));
      }

      listRegisters[index] = registro;
      final bool result = await _salvarLocalmente(listRegisters);
      return Right(result);
    } catch (e, s) {
      log("Erro ao atualizar registro: $e", error: e, stackTrace: s);
      return Left(
          RepositoryException(message: 'Erro ao atualizar o registro.'));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> deleteRegisterRepository(
      RegisterModel registro) async {
    try {
      final List<RegisterModel> listRegisters = await _getListRegister();

      final int beforeCount = listRegisters.length;
      listRegisters.removeWhere((reg) => reg.id == registro.id);

      if (beforeCount == listRegisters.length) {
        return Left(RepositoryException(message: 'Registro não encontrado.'));
      }

      final bool result = await _salvarLocalmente(listRegisters);
      return Right(result);
    } catch (e, s) {
      log("Erro ao remover registro: $e", error: e, stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao remover o registro.'));
    }
  }
}

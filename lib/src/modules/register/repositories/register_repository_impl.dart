// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:convert';
import 'dart:developer';

import 'package:keezy/src/core/data/services/secure_storage_service.dart';
import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/either/unit.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/register/repositories/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  RegisterRepositoryImpl();

  final SecureStorageService _secureStorageService = SecureStorageService();

  final RegisterHive _registerHive = RegisterHive();

  static const _keyRegistros = 'registers';

  Future<List<RegisterModel>> _getListRegister() async {
    try {
      final List<RegisterModel>? listRegisters =
           _registerHive.getAllRegisters();

      if (listRegisters == null || listRegisters.isEmpty) {
        return [];
      }

      return listRegisters;
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
      await _registerHive.addRegister(register);

      return Right(true);
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
  Future<Either<RepositoryException, Unit>> deleteRegisterRepository(
      RegisterModel registro) async {
    try {
      final List<RegisterModel> listRegisters = await _getListRegister();

      final int beforeCount = listRegisters.length;
      listRegisters.removeWhere((reg) => reg.id == registro.id);

      if (beforeCount == listRegisters.length) {
        return Left(RepositoryException(message: 'Registro não encontrado.'));
      }

      _registerHive.deleteRegister(registro.id);
     // final bool result = await _salvarLocalmente(listRegisters);
      return Right(unit);

    } catch (e, s) {
      log("Erro ao remover registro: $e", error: e, stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao remover o registro.'));
    }
  }
}

// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'dart:developer';

import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/either/unit.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/register/data/register_hive.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/register/repositories/register_repository.dart';


class RegisterRepositoryImpl implements RegisterRepository {
  RegisterRepositoryImpl();

  final RegisterHive _registerHive = RegisterHive();

  @override
  Future<Either<RepositoryException, List<RegisterModel>>> getAllRegisterRepository() async {
    try {
      final list = await _registerHive.getAllRegisters();
      // garantir lista não nula
      final safeList = list ?? <RegisterModel>[];
      return Right(safeList);
    } catch (_) {
      log('Erro ao buscar registros.');
      return Left(RepositoryException(message: 'Erro ao buscar os registros.'));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> saveRegisterRepository(RegisterModel register) async {
    try {
      await _registerHive.addRegister(register);
      return Right(true);
    } catch (_) {
      log('Erro ao salvar registro.');
      return Left(RepositoryException(message: 'Erro ao salvar o registro.'));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> updateRegisterRepository(RegisterModel register) async {
    try {
      final exists = await _registerHive.exists(register.id);
      if (!exists) {
        return Left(RepositoryException(message: 'Registro não encontrado para atualizar.'));
      }
      await _registerHive.updateRegister(register);
      return Right(true);
    } catch (_) {
      log('Erro ao atualizar registro.');
      return Left(RepositoryException(message: 'Erro ao atualizar o registro.'));
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteRegisterRepository(RegisterModel register) async {
    try {
      final exists = await _registerHive.exists(register.id);
      if (!exists) {
        return Left(RepositoryException(message: 'Registro não encontrado.'));
      }
      await _registerHive.deleteRegister(register.id);
      return Right(unit);
    } catch (_) {
      log('Erro ao remover registro.');
      return Left(RepositoryException(message: 'Erro ao remover o registro.'));
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteAllRegistersRepository() async {
    try {
      await _registerHive.clearAll();
      return Right(unit);
    } catch (_) {
      log('Erro ao remover registros.');
      return Left(RepositoryException(message: 'Erro ao remover os registros.'));
    }
  }


  @override
Future<Either<RepositoryException, bool>> saveListRegisterRepository(
  List<RegisterModel> listRegisters,
) async {
  try {
    await _registerHive.replaceAll(listRegisters); 
    return Right(true);
  } catch (_) {
    log('Erro ao salvar lista de registros.');
    return Left(RepositoryException(message: 'Erro ao salvar todos registros.'));
  }
}

}

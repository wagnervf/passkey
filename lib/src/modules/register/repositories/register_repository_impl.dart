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
    } catch (e, s) {
      log('Erro em getAllRegisterRepository: $e', stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao buscar os registros.'));
    }
  }

  @override
  Future<Either<RepositoryException, bool>> saveRegisterRepository(RegisterModel register) async {
    try {
      await _registerHive.addRegister(register);
      return Right(true);
    } catch (e, s) {
      log('Erro em saveRegisterRepository: $e', stackTrace: s);
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
    } catch (e, s) {
      log('Erro em updateRegisterRepository: $e', stackTrace: s);
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
    } catch (e, s) {
      log('Erro em deleteRegisterRepository: $e', stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao remover o registro.'));
    }
  }

  @override
  Future<Either<RepositoryException, Unit>> deleteAllRegistersRepository() async {
    try {
      await _registerHive.clearAll();
      return Right(unit);
    } catch (e, s) {
      log('Erro em deleteAllRegistersRepository: $e', stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao remover os registros.'));
    }
  }

  // opcional: salvar lista (p.ex. import em massa)
  @override
  Future<Either<RepositoryException, bool>> saveListRegisterRepository(List<RegisterModel> listRegisters) async {
    try {
      // substitui tudo por nova lista
      await _registerHive.replaceAll(listRegisters);
      return Right(true);
    } catch (e, s) {
      log('Erro em saveListRegisterRepository: $e', stackTrace: s);
      return Left(RepositoryException(message: 'Erro ao salvar registros.'));
    }
  }
}


// class RegisterRepositoryImpl implements RegisterRepository {
//   RegisterRepositoryImpl();

//   final SecureStorageService _secureStorageService = SecureStorageService();

//   final RegisterHive _registerHive = RegisterHive();

//   static const _keyRegistros = 'registers';

//   Future<List<RegisterModel>> _getListRegister() async {
//     try {
//       final List<RegisterModel>? listRegisters = _registerHive
//           .getAllRegisters();

//       if (listRegisters == null || listRegisters.isEmpty) {
//         return [];
//       }

//       return listRegisters;
//     } catch (e, s) {
//       log("Erro ao buscar registros: $e", error: e, stackTrace: s);
//       return [];
//     }
//   }


//   @override
//   Future<Either<RepositoryException, List<RegisterModel>>>
//   getAllRegisterRepository() async {
//     try {
//       final List<RegisterModel> listRegisters = await _getListRegister();
//       return Right(listRegisters);
//     } catch (e, s) {
//       log("Erro ao obter registros: $e", error: e, stackTrace: s);
//       return Left(RepositoryException(message: 'Erro ao buscar os registros.'));
//     }
//   }

//   @override
//   Future<Either<RepositoryException, bool>> saveRegisterRepository(
//     RegisterModel register,
//   ) async {
//     try {
//       await _registerHive.addRegister(register);

//       return Right(true);
//     } catch (e, s) {
//       log("Erro ao salvar registro: $e", error: e, stackTrace: s);
//       return Left(RepositoryException(message: 'Erro ao salvar o registro.'));
//     }
//   }

//   @override
//   Future<Either<RepositoryException, bool>> updateRegisterRepository(
//     RegisterModel registro,
//   ) async {
//     try {
//       final List<RegisterModel> listRegisters = await _getListRegister();
//       final int index = listRegisters.indexWhere(
//         (reg) => reg.id == registro.id,
//       );

//       if (index == -1) {
//         return Left(RepositoryException(message: 'Registro não encontrado.'));
//       }

//       listRegisters[index] = registro;
//       await _registerHive.updateRegister(registro);
//       return Right(true);

//     } catch (e, s) {
//       log("Erro ao atualizar registro: $e", error: e, stackTrace: s);
//       return Left(
//         RepositoryException(message: 'Erro ao atualizar o registro.'),
//       );
//     }
//   }

//   @override
//   Future<Either<RepositoryException, Unit>> deleteRegisterRepository(
//     RegisterModel registro,
//   ) async {
//     try {
//       final List<RegisterModel> listRegisters = await _getListRegister();

//       final int beforeCount = listRegisters.length;
//       listRegisters.removeWhere((reg) => reg.id == registro.id);

//       if (beforeCount == listRegisters.length) {
//         return Left(RepositoryException(message: 'Registro não encontrado.'));
//       }

//       _registerHive.deleteRegister(registro.id);
//       // final bool result = await _salvarLocalmente(listRegisters);
//       return Right(unit);
//     } catch (e, s) {
//       log("Erro ao remover registro: $e", error: e, stackTrace: s);
//       return Left(RepositoryException(message: 'Erro ao remover o registro.'));
//     }
//   }

//   @override
//   Future<Either<RepositoryException, Unit>>
//   deleteAllRegistersRepository() async {
//     try {
//       _registerHive.clearAll();
//       return Right(unit);
//     } catch (e, s) {
//       log("Erro ao remover registro");
//       return Left(RepositoryException(message: 'Erro ao remover o registro.'));
//     }
//   }


// }

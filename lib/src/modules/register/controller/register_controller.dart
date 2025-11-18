import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/either/unit.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/register/controller/register_state.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/register/repositories/register_repository.dart';


class RegisterController extends Cubit<RegisterState> {
  final RegisterRepository registerRepository;

  RegisterController({required this.registerRepository})
      : super(RegisterInitial());

  List<RegisterModel> _listRegisters = [];
  List<RegisterModel> get listRegisters => _listRegisters;

  
  Future<Either<RepositoryException, Unit>> getRegisterController() async {
    try {
      emit(RegisterLoading());

      final register = await registerRepository.getAllRegisterRepository();

      switch (register) {
        case Left(value: RepositoryException(:final message)):
          emit(RegisterError(message));
          return Left(RepositoryException(message: message));

        case Right<RepositoryException, List<RegisterModel>>(
            value: final result):
          _listRegisters = List.from(result)
            ..sort((a, b) => b.id.compareTo(a.id));

          emit(RegisterLoaded(register: _listRegisters));
          return Right(unit);
      }
    } catch (e, s) {
      log("Erro inesperado ao buscar registros: $e", stackTrace: s);
      const message = "Erro ao buscar Register";
      emit(RegisterError(message));
      return Left(RepositoryException(message: message));
    }
  }

 
  Future<bool> saveAndUpdateRegisterController(
      RegisterModel novoRegister) async {
    emit(RegisterLoading());

    try {
      final result =
          await registerRepository.saveRegisterRepository(novoRegister);

      switch (result) {
        case Left(value: RepositoryException()):
          return false;

        case Right(value: bool()):
          await getRegisterController();
          return true;
      }
    } catch (e, s) {
      log("Erro inesperado ao salvar/atualizar registro: $e", stackTrace: s);
      emit(RegisterError("Erro inesperado ao salvar registro."));
      return false;
    }
  }

  // ============================================================
  // DELETE ONE
  // ============================================================
  Future<bool> deleteRegisterController(RegisterModel registro) async {
    emit(RegisterLoading());

    try {
      final result =
          await registerRepository.deleteRegisterRepository(registro);

      switch (result) {
        case Left(value: RepositoryException()):
          return false;

        case Right(value: Unit()):
          await getRegisterController();
          return true;
      }
    } catch (e, s) {
      log("Erro inesperado ao remover registro: $e", stackTrace: s);
      emit(RegisterError("Erro ao remover"));
      return false;
    }
  }

  // ============================================================
  // IMPORTAR ITEM ÚNICO VIA JSON
  // ============================================================
  Future<void> importarUmRegistro(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent);
      final registro = RegisterModel.fromMap(data);

      await saveAndUpdateRegisterController(registro);
    } catch (e) {
      log("Erro ao importar registro: $e");
    }
  }

  // ============================================================
  // LISTA PARA EXPORTAÇÃO
  // ============================================================
  Future<List<RegisterModel>?> getRegisterForExportCsv() async {
    try {
      final register = await registerRepository.getAllRegisterRepository();

      switch (register) {
        case Left():
          return null;

        case Right<RepositoryException, List<RegisterModel>>(
            value: final result):
          return List.from(result)
            ..sort((a, b) => b.id.compareTo(a.id));
      }
    } catch (e) {
      log("Erro ao buscar registros para exportação: $e");
      return null;
    }
  }

  // ============================================================
  // DELETE ALL
  // ============================================================
  Future<bool> deleteAllRegistersController() async {
    emit(RegisterLoading());
    try {
      final result =
          await registerRepository.deleteAllRegistersRepository();

      switch (result) {
        case Left():
          return false;

        case Right():
          await getRegisterController();
          return true;
      }
    } catch (e) {
      log("Erro ao remover todos os registros: $e");
      return false;
    }
  }
}


// class RegisterController extends Cubit<RegisterState> {
//   final RegisterRepository registerRepository;

//   RegisterController({required this.registerRepository})
//       : super(RegisterInitial());

//   List<RegisterModel> _listRegisters = [];
//   List<RegisterModel> get listRegisters => _listRegisters;

//   Future<Either<RepositoryException, Unit>> getRegisterController() async {
//     try {
//       emit(RegisterLoading());

//       final register = await registerRepository.getAllRegisterRepository();

//       log(register.toString());

      // switch (register) {
      //   case Left(value: RepositoryException(:final message)):
      //     emit(RegisterError(message));
      //     return Left(RepositoryException(message: message));

      //   case Right<RepositoryException, List<RegisterModel>>(
      //       value: final result
      //     ):
      //     _listRegisters = result;

      //     _listRegisters.sort((a, b) => b.id.compareTo(a.id));

      //     emit(RegisterLoaded(register: _listRegisters));
      //     return Right(unit);
      // }
//     } on Exception catch (e) {
//       log(e.toString());
//       const message = 'Erro ao buscar Register';
//       emit(RegisterError(message));
//       return Left(RepositoryException(message: message));
//     }
//   }

//   Future<bool> saveAndUpdateRegisterController(
//       RegisterModel novoRegister) async {
//     emit(RegisterLoading());
//     try {
//       final register =
//           await registerRepository.saveRegisterRepository(novoRegister);

//       switch (register) {
//         case Left<RepositoryException, bool>():
//           return false;

//         case Right<RepositoryException, bool>():
//           getRegisterController();
//           return true;
//       }
//     } catch (e, s) {
//       log('Exceção inesperada ao salvar registro: $e\n$s');
//       emit(RegisterError('Erro inesperado ao salvar registro.'));
//       return false;
//     }
//   }


//   Future<bool> deleteRegisterController(RegisterModel registro) async {
//     emit(RegisterLoading());
//     try {
//       final register =
//           await registerRepository.deleteRegisterRepository(registro);

//       switch (register) {
//         case Left<RepositoryException, Unit>():
//           return false;

//         case Right<RepositoryException, Unit>():
//           await getRegisterController();

//           return true;
//       }
//     } on Exception catch (e) {
//       log(e.toString());
//       const message = 'Erro ao remover';
//       emit(RegisterError(message));
//       return false;
//     }
//   }

//   Future<void> importarUmRegistro(String jsonContent) async {
//     try {
//       // Decodifica o texto JSON recebido
//       var registroJson = jsonDecode(jsonContent);

//       log(registroJson.toString());

//       var registroFormatado = RegisterModel.fromMap(registroJson);

//       await saveAndUpdateRegisterController(registroFormatado);
//     } catch (e) {
//       log('Erro ao importar registro: $e');
//       //  return null;
//     }
//   }

//   Future<List<RegisterModel>?>? getRegisterForExportCsv() async {
//     try {
//       final register = await registerRepository.getAllRegisterRepository();

//       log(register.toString());

//       switch (register) {
//         case Left(value: RepositoryException()):
//           return null;

//         case Right<RepositoryException, List<RegisterModel>>(
//             value: final result
//           ):
//           result.sort((a, b) => b.id.compareTo(a.id));

//           return result;
//       }
//     } on Exception catch (e) {
//       log(e.toString());
//       return null;
//     }
//   }



//  Future<bool> deleteAllRegistersController() async {
//     emit(RegisterLoading());
//     try {
//       final register =
//           await registerRepository.deleteAllRegistersRepository();

//       switch (register) {
//         case Left<RepositoryException, Unit>():
//           return false;

//         case Right<RepositoryException, Unit>():
//           await getRegisterController();

//           return true;
//       }
//     } on Exception catch (e) {
//       log(e.toString());
//       const message = 'Erro ao remover';
//       emit(RegisterError(message));
//       return false;
//     }
//   }
// }

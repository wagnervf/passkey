import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passkey/src/core/either/either.dart';
import 'package:passkey/src/core/either/unit.dart';
import 'package:passkey/src/core/exceptions/repository_exception.dart';
import 'package:passkey/src/modules/register/controller/register_state.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';
import 'package:passkey/src/modules/register/repositories/register_repository.dart';

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
            value: final result
          ):
          _listRegisters = result;

          emit(RegisterLoaded(register: _listRegisters));
          return Right(unit);
      }
    } on Exception catch (e) {
      log(e.toString());
      const message = 'Erro ao buscar Register';
      emit(RegisterError(message));
      return Left(RepositoryException(message: message));
    }
  }

  Future<bool> saveRegisterController(RegisterModel novoRegister) async {
    emit(RegisterLoading());
    try {
      final register =
          await registerRepository.saveRegisterRepository(novoRegister);

      switch (register) {
        case Left():
          return false;

        case Right<RepositoryException, bool>():
          getRegisterController();
          return true;
      }
    } on Exception catch (e) {
      log(e.toString());
      const message = 'Erro ao buscar Register';
      emit(RegisterError(message));
      return false;
    }
  }

    Future<bool> saveListRegisterController(List<RegisterModel> registers) async {
    emit(RegisterLoading());
    try {
      
     final register =
          await registerRepository.saveListRegisterRepository(registers);

      switch (register) {
        case Left():
          return false;

        case Right<RepositoryException, bool>():
          getRegisterController();
          return true;
      }
    } on Exception catch (e) {
      log(e.toString());
      const message = 'Erro ao buscar Register';
      emit(RegisterError(message));
      return false;
    }
  }


  Future<bool> updateRegisterController(RegisterModel updatedRegistro) async {
    emit(RegisterLoading());
    try {
      final register =
          await registerRepository.updateRegisterRepository(updatedRegistro);

      switch (register) {
        case Left():
          return false;

        case Right<RepositoryException, bool>():
          await getRegisterController();

          return true;
      }
    } on Exception catch (e) {
      log(e.toString());
      const message = 'Erro ao buscar Register';
      emit(RegisterError(message));
      return false;
    }
  }

  Future<bool> deleteRegisterController(RegisterModel updatedRegistro) async {
    emit(RegisterLoading());
    try {
      final register =
          await registerRepository.deleteRegisterRepository(updatedRegistro);

      switch (register) {
        case Left():
          return false;

        case Right<RepositoryException, bool>():
          await getRegisterController();

          return true;
      }
    } on Exception catch (e) {
      log(e.toString());
      const message = 'Erro ao buscar Register';
      emit(RegisterError(message));
      return false;
    }
  }

  Future<void> importarUmRegistro(String jsonContent) async {
    try {
      // Decodifica o texto JSON recebido
      var registroJson = jsonDecode(jsonContent);

      log(registroJson.toString());

      var registroFormatado = RegisterModel.fromJson(registroJson);

      await saveRegisterController(registroFormatado);
    } catch (e) {
      log('Erro ao importar registro: $e');
      //  return null;
    }
  }
}

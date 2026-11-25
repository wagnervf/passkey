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
          value: final result,
        ):
          _listRegisters = List.from(result)
            ..sort((a, b) => b.id.compareTo(a.id));

          emit(RegisterLoaded(register: _listRegisters));
          return Right(unit);
      }
    } catch (_) {
      log('Erro inesperado ao buscar registros.');
      const message = "Erro ao buscar Register";
      emit(RegisterError(message));
      return Left(RepositoryException(message: message));
    }
  }

  Future<bool> saveAndUpdateRegisterController(
    RegisterModel novoRegister,
  ) async {
    emit(RegisterLoading());

    try {
      final result = await registerRepository.saveRegisterRepository(
        novoRegister,
      );

      switch (result) {
        case Left(value: RepositoryException()):
          return false;

        case Right(value: bool()):
          await getRegisterController();
          return true;
      }
    } catch (_) {
      log('Erro inesperado ao salvar ou atualizar registro.');
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
      final result = await registerRepository.deleteRegisterRepository(
        registro,
      );

      switch (result) {
        case Left(value: RepositoryException()):
          return false;

        case Right(value: Unit()):
          await getRegisterController();
          return true;
      }
    } catch (_) {
      log('Erro inesperado ao remover registro.');
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
    } catch (_) {
      log('Erro ao importar registro.');
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
          value: final result,
        ):
          return List.from(result)..sort((a, b) => b.id.compareTo(a.id));
      }
    } catch (_) {
      log('Erro ao buscar registros para exportação.');
      return null;
    }
  }

  // ============================================================
  // DELETE ALL
  // ============================================================
  Future<bool> deleteAllRegistersController() async {
    emit(RegisterLoading());
    try {
      final result = await registerRepository.deleteAllRegistersRepository();

      switch (result) {
        case Left():
          return false;

        case Right():
          await getRegisterController();
          return true;
      }
    } catch (_) {
      log('Erro ao remover todos os registros.');
      return false;
    }
  }

  Future<bool> saveListRegistersController(List<RegisterModel> list) async {
    emit(RegisterLoading());
    try {
      final result = await registerRepository.saveListRegisterRepository(list);
      switch (result) {
        case Left(value: RepositoryException()):
          emit(RegisterError('Erro ao salvar lista'));
          return false;

        case Right(value: bool()):
          await getRegisterController(); // recarrega a lista
          return true;
      }
    } catch (_) {
      log('Erro ao salvar lista de registros.');
      emit(RegisterError('Erro inesperado ao salvar lista.'));
      return false;
    }
  }

  Future<bool> addNewRegistersController(List<RegisterModel> records) async {
    emit(RegisterLoading());
    try {
      final result = await registerRepository.addNewRegistersRepository(
        records,
      );
      // A failed batch may have written some new records. Refresh the visible
      // list so a retry can skip those records without touching older ones.
      final refreshed = await getRegisterController();
      return switch (result) {
        Left() => false,
        Right(value: final saved) => saved && refreshed is Right,
      };
    } catch (_) {
      log('Erro ao importar lista de registros.');
      emit(RegisterError('Erro ao importar registros.'));
      return false;
    }
  }
}

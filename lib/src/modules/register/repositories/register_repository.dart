import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/either/unit.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';

abstract interface class RegisterRepository {

  Future<Either<RepositoryException, List<RegisterModel>>>
  getAllRegisterRepository();
  Future<Either<RepositoryException, bool>> saveRegisterRepository(
    RegisterModel register,
  );
  Future<Either<RepositoryException, bool>> updateRegisterRepository(
    RegisterModel register,
  );
  Future<Either<RepositoryException, Unit>> deleteRegisterRepository(
    RegisterModel register,
  );
  Future<Either<RepositoryException, Unit>> deleteAllRegistersRepository();
  Future<Either<RepositoryException, bool>> saveListRegisterRepository(
    List<RegisterModel> listRegisters,
  );
}

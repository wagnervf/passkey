import 'package:keezy/src/core/either/either.dart';
import 'package:keezy/src/core/exceptions/repository_exception.dart';
import 'package:keezy/src/modules/register/model/registro_model.dart';

abstract interface class RegisterRepository {
Future<Either<RepositoryException, List<RegisterModel>>> getAllRegisterRepository();
Future<Either<RepositoryException, bool>> saveRegisterRepository(RegisterModel registers);
Future<Either<RepositoryException, bool>> saveListRegisterRepository(List<RegisterModel> registers);

Future<Either<RepositoryException, bool>> updateRegisterRepository(RegisterModel updatedRegistro);
Future<Either<RepositoryException, bool>> deleteRegisterRepository(RegisterModel deleteRegistro);

}


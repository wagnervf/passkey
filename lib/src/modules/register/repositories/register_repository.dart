import 'package:passkey/src/core/either/either.dart';
import 'package:passkey/src/core/exceptions/repository_exception.dart';
import 'package:passkey/src/modules/register/model/registro_model.dart';

abstract interface class RegisterRepository {
Future<Either<RepositoryException, List<RegisterModel>>> getAllRegisterRepository();
Future<Either<RepositoryException, bool>> saveRegisterRepository(RegisterModel registers);
Future<Either<RepositoryException, bool>> saveListRegisterRepository(List<RegisterModel> registers);

Future<Either<RepositoryException, bool>> updateRegisterRepository(RegisterModel updatedRegistro);
Future<Either<RepositoryException, bool>> deleteRegisterRepository(RegisterModel deleteRegistro);



//Future<ShareResultStatus> exportarViaArquivoRepository();
/*
Future<Either<RepositoryException, bool>> importarViaArquivoRepository();

Future<bool> exportarUmRegistroRepository(RegisterModel registro);

Future<Either<RepositoryException, bool>> importarUmRegistroRepository();
*/
}


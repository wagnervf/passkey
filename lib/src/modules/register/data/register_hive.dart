import 'package:hive/hive.dart';
import 'package:keezy/src/core/installed_apps/installed_app_model.dart';
import 'package:keezy/src/modules/register/model/register_model.dart';
import 'package:keezy/src/modules/type_register/type_register_model.dart';

class RegisterHive {
  static const String boxName = 'registerBox';
  static late final Box<RegisterModel> _registerBox;

  // Inicialização do Hive e registro do adapter
  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RegisterModelAdapter());
    }

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TypeRegiterModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(InstalledAppModelAdapter());
    }

    _registerBox = await Hive.openBox<RegisterModel>(boxName);
  }

  // Adiciona ou atualiza um registro
  Future<void> addRegister(RegisterModel register) async {
    await _registerBox.put(register.id, register);
  }

  // Busca um registro por ID
  RegisterModel? getRegister(String id) {
    return _registerBox.get(id);
  }

  // Remove um registro por ID
  Future<void> deleteRegister(String id) async {
    await _registerBox.delete(id);
  }

  // Limpa todos os registros
  Future<void> clearAll() async {
    await _registerBox.clear();
  }

  // Lista todos os registros
  List<RegisterModel>? getAllRegisters() {
    return _registerBox.values.toList();
  }
}

// class RegisterHive {
  
//   static const String boxName = 'registerBox';
//   static const String key = 'registerKey';
//   static late final Box<RegisterModel> _registerBox;

//  static Future<void> init() async {
//     Hive.registerAdapter(RegisterModelAdapter());
//     _registerBox = await Hive.openBox<RegisterModel>(boxName);
//   }

//    Future<void> addRegister(RegisterModel register) async {
//     await _registerBox.put(register.id, register);
//   }
//    Future<RegisterModel?> getRegister() async {
//     return _registerBox.get(key);
//   }
//    Future<void> deleteRegister() async {
//     await _registerBox.delete(key);
//   }
//    Future<void> clearAll() async {
//     await _registerBox.clear();
//   }
//    Future<List<RegisterModel>?> getAllRegisters() async {
//     return _registerBox.values.toList();
//   }



// Future<Either<RepositoryException, bool>> saveRegisterRepository(
//     RegisterModel register) async {
//   try {
//     final box = await Hive.openBox<RegisterModel>('registers');

//     // Utiliza o id como chave
//     await box.put(register.id, register);

//     return Right(true);
//   } catch (e, s) {
//     log("Erro ao salvar registro: $e", error: e, stackTrace: s);
//     return Left(RepositoryException(message: 'Erro ao salvar o registro.'));
//   }
// }

  //  static const _boxName = 'senhas';
  // late Box<Senha> _box;

  // Future<void> init() async {
  //   if (!Hive.isAdapterRegistered(0)) {
  //     Hive.registerAdapter(SenhaAdapter());
  //   }
  //   _box = await Hive.openBox<Senha>(_boxName);
  // }

  // List<Senha> getAll() => _box.values.toList();

  // Future<void> add(Senha senha) async {
  //   await _box.add(senha);
  // }



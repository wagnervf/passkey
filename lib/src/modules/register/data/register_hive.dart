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


import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static late SharedPreferences _sharedPreferences;

  SharedPreferencesService._internal();

  factory SharedPreferencesService() {
    if (_instance == null) {
      throw Exception("SharedPreferencesService não inicializado. Chame SharedPreferencesService.init() primeiro.");
    }
    return _instance!;
  }

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _instance = SharedPreferencesService._internal();
  }

  SharedPreferences get sharedPreferences => _sharedPreferences;
}

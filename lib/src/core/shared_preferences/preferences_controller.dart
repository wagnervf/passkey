import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesController {
  final SharedPreferences sharedPreferences; 

  PreferencesController( {
    required this.sharedPreferences
  });

  

  Future<bool> savePreferencesBool(String key, bool value) async {
    if(key.isEmpty) return false;
    return await sharedPreferences.setBool(key, value);
  }

  Future<bool> getPreferencesBool(String key) async {
    return sharedPreferences.getBool(key) ?? false;
  }

  Future<bool> savePreferencesString(String key, String value) async {
    if(key.isEmpty) return false;
    return sharedPreferences.setString(key, value);
  }

  saveLastLogin() async {
    late DateTime now = DateTime.now();
    late String formattedDateTime = '${DateFormat('dd/MM/yyyy').format(now)} às ${DateFormat('HH:mm:ss').format(now)}';
    return await sharedPreferences.setString('lastLoginDateTime', formattedDateTime);
  }

  Future<String> getLastLogin() async {
    late String dateTime = sharedPreferences.getString('lastLoginDateTime') ?? 'Nenhum login anterior registrado.';
    return dateTime;
  }
}

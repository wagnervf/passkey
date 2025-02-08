// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:passkey/src/core/shared_preferences/preferences_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracoesController extends ChangeNotifier {
  ConfiguracoesController({required this.sharedPreferences});

  final SharedPreferences
      sharedPreferences; // = SharedPreferencesService().sharedPreferences;

  late PreferencesController preferencesController =
      PreferencesController(sharedPreferences: sharedPreferences);

  late bool _termoDeUso = false;
  bool get termodeUso => _termoDeUso;

  Future<bool> saveAceitarTermoUso(bool value) async {
    _termoDeUso = value;
    final result =
        await preferencesController.savePreferencesBool('termoDeUso', value);
    notifyListeners();
    return result;
  }

  Future<bool> getAceitarTermoUso() async {
    _termoDeUso = await preferencesController.getPreferencesBool('termoDeUso');
    notifyListeners();
    return _termoDeUso;
  }
}

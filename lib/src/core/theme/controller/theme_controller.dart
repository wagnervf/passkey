import 'package:flutter/material.dart';
import 'package:passkey/src/core/theme/services/theme_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({
    required this.themeService,
  }) {
    checkTheme();
  }

  final ThemeService themeService;   
  late bool _isDark = false;  
  bool get isDark => _isDark;

  checkTheme() async{
    await isThemeDark();
  }

   Future<void> toggleTheme() async {
    _isDark = !_isDark;
    await themeService.saveTheme(_isDark);
    notifyListeners();
  }

   Future<void> isThemeDark() async {
    _isDark = await themeService.getTheme();

      notifyListeners();
  }
}


import 'package:keezy/src/core/theme/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeServiceImpl implements ThemeService{
  final String _themeKey = 'themeDark';
  
   @override
  Future<void> saveTheme(bool isDark)async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
   
  }

   @override
  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    var result = prefs.getBool(_themeKey);
    return result ?? false;
  }
  
 
}
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'is_dark_mode';
  
  final _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool(_themeKey) ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode.value);
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}

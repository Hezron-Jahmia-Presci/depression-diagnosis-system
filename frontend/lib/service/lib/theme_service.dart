import 'package:depression_diagnosis_system/service/base_service.dart';

class ThemeService extends BaseService {
  static const _themeKey = 'isDarkMode';

  Future<bool> isDarkMode() async {
    final value = await storage.read(key: _themeKey);
    return value == 'true'; // default to false if null
  }

  Future<void> setDarkMode(bool isDark) async {
    await storage.write(key: _themeKey, value: isDark.toString());
  }

  Future<void> clearThemePreference() async {
    await storage.delete(key: _themeKey);
  }
}

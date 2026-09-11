import 'package:flutter/foundation.dart';

import 'app_language.dart';

class LanguageController extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.turkish;

  AppLanguage get currentLanguage => _currentLanguage;

  void changeLanguage(AppLanguage language) {
    if (_currentLanguage == language) {
      return;
    }

    _currentLanguage = language;
    notifyListeners();
  }

  void toggleLanguage() {
    changeLanguage(
      _currentLanguage == AppLanguage.turkish
          ? AppLanguage.english
          : AppLanguage.turkish,
    );
  }
}

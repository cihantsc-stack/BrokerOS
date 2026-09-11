import 'package:flutter/widgets.dart';

import 'app_language.dart';
import 'app_translations.dart';
import 'language_controller.dart';

class AppLanguageScope extends InheritedNotifier<LanguageController> {
  const AppLanguageScope({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLanguageScope>();

    assert(scope != null, 'AppLanguageScope bulunamadı.');

    return scope!.notifier!;
  }
}

extension LocalizationExtension on BuildContext {
  LanguageController get languageController {
    return AppLanguageScope.of(this);
  }

  AppLanguage get currentLanguage {
    return languageController.currentLanguage;
  }

  String tr(String key) {
    return AppTranslations.translate(language: currentLanguage, key: key);
  }
}

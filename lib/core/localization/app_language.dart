enum AppLanguage { turkish, english }

extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.turkish:
        return 'tr';
      case AppLanguage.english:
        return 'en';
    }
  }

  String get label {
    switch (this) {
      case AppLanguage.turkish:
        return 'Türkçe';
      case AppLanguage.english:
        return 'English';
    }
  }
}

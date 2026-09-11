import 'package:flutter/material.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/localization_extension.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';
import '../../shared/widgets/page_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = context.languageController;
    final currentLanguage = context.currentLanguage;
    final isTurkish = currentLanguage == AppLanguage.turkish;

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageTitle(context.tr('profile')),
          const SizedBox(height: 18),
          BrokerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: BrokerColors.crocGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.language_rounded,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('language'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            isTurkish
                                ? 'Uygulamanın görüntüleneceği dili seç.'
                                : 'Select the application language.',
                            style: const TextStyle(
                              color: BrokerColors.textSoft,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _LanguageOption(
                  title: 'Türkçe',
                  subtitle: isTurkish
                      ? 'Uygulamayı Türkçe kullan'
                      : 'Use the application in Turkish',
                  selected: currentLanguage == AppLanguage.turkish,
                  onTap: () {
                    languageController.changeLanguage(AppLanguage.turkish);
                  },
                ),
                const SizedBox(height: 10),
                _LanguageOption(
                  title: 'English',
                  subtitle: isTurkish
                      ? 'Uygulamayı İngilizce kullan'
                      : 'Use the application in English',
                  selected: currentLanguage == AppLanguage.english,
                  onTap: () {
                    languageController.changeLanguage(AppLanguage.english);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          BrokerCard(
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: BrokerColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTurkish
                        ? 'Tema, risk profili ve abonelik ayarları burada olacak.'
                        : 'Theme, risk profile and subscription settings will be available here.',
                    style: const TextStyle(
                      color: BrokerColors.textSoft,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? BrokerColors.primary.withValues(alpha: 0.12)
                : BrokerColors.cardDeep.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? BrokerColors.primary
                  : BrokerColors.border.withValues(alpha: 0.75),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: selected ? BrokerColors.crocGradient : null,
                  color: selected
                      ? null
                      : BrokerColors.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.language_rounded,
                  color: selected ? Colors.black : BrokerColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: selected ? Colors.white : BrokerColors.textSoft,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: BrokerColors.textMuted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? BrokerColors.primary : BrokerColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

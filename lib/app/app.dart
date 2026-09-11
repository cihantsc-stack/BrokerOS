import 'package:flutter/material.dart';

import '../core/localization/language_controller.dart';
import '../core/localization/localization_extension.dart';
import 'responsive_home.dart';
import 'theme.dart';

class BrokerOSApp extends StatefulWidget {
  const BrokerOSApp({super.key});

  @override
  State<BrokerOSApp> createState() => _BrokerOSAppState();
}

class _BrokerOSAppState extends State<BrokerOSApp> {
  final LanguageController _languageController = LanguageController();

  @override
  Widget build(BuildContext context) {
    return AppLanguageScope(
      controller: _languageController,
      child: MaterialApp(
        title: 'CROC AI',
        debugShowCheckedModeBanner: false,
        theme: BrokerTheme.dark,
        home: const ResponsiveHome(),
      ),
    );
  }
}

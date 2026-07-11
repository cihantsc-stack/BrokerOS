import 'package:flutter/material.dart';

import 'navigation.dart';
import 'theme.dart';

class BrokerOSApp extends StatelessWidget {
  const BrokerOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broker OS',
      debugShowCheckedModeBanner: false,
      theme: BrokerTheme.dark,
      home: const BrokerNavigation(),
    );
  }
}

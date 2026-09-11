import 'package:flutter/material.dart';

import 'features/bist100/bist100_intelligence_preview_screen.dart';

void main() {
  const String apiKey = String.fromEnvironment(
    'TWELVE_DATA_API_KEY',
    defaultValue: '',
  );

  runApp(const Bist100PreviewApp(apiKey: apiKey));
}

class Bist100PreviewApp extends StatelessWidget {
  final String apiKey;

  const Bist100PreviewApp({super.key, required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Broker OS BIST 100 Preview',
      theme: ThemeData.dark(useMaterial3: true),
      home: Bist100IntelligencePreviewScreen(apiKey: apiKey),
    );
  }
}

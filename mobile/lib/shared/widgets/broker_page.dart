import 'package:flutter/material.dart';

class BrokerPage extends StatelessWidget {
  final Widget child;

  const BrokerPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [child],
      ),
    );
  }
}

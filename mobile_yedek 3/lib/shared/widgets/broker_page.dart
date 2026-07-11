import 'package:flutter/material.dart';
import '../design/broker_colors.dart';

class BrokerPage extends StatelessWidget {
  final Widget child;

  const BrokerPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrokerColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 96),
          children: [child],
        ),
      ),
    );
  }
}

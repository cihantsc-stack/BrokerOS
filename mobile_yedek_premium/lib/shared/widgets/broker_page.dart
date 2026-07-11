import 'package:flutter/material.dart';
import '../design/broker_colors.dart';

class BrokerPage extends StatelessWidget {
  final Widget child;

  const BrokerPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BrokerColors.background,
            BrokerColors.backgroundSoft,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                110,
              ),
              children: [
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
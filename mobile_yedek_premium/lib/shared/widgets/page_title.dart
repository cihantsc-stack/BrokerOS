import 'package:flutter/material.dart';
import '../design/broker_colors.dart';

class PageTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const PageTitle(
    this.title, {
    super.key,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return BrokerColors.crocGradient.createShader(bounds);
          },
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}
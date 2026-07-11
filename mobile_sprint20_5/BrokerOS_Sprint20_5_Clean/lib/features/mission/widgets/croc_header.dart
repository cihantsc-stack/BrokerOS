import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class CrocHeader extends StatelessWidget {
  const CrocHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: BrokerColors.crocGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: BrokerColors.primary.withOpacity(.25),
                blurRadius: 26,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: Colors.black,
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CROC AI',
                style: TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                  height: 1,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'powered by Broker OS',
                style: TextStyle(
                  color: BrokerColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

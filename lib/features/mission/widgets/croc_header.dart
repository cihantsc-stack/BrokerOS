import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';

class CrocHeader extends StatelessWidget {
  const CrocHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          height: compact ? 118 : 148,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF03080C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: BrokerColors.primary.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: BrokerColors.primary.withValues(alpha: 0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/croc_banner.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'croc_banner.png bulunamadı',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

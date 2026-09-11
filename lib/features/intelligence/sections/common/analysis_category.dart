import 'package:flutter/material.dart';

import '../../../../shared/design/broker_colors.dart';

class AnalysisCategory extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const AnalysisCategory({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      separated.add(children[i]);
      if (i != children.length - 1) {
        separated.add(const SizedBox(height: 14));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: BrokerColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrokerColors.primary.withValues(alpha: 0.09)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: BrokerColors.primary),
          title: Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textMain,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(10, 5, 10, 12),
          children: separated,
        ),
      ),
    );
  }
}

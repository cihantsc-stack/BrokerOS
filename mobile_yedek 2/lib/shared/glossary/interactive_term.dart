import 'package:flutter/material.dart';

import '../../core/theme/croc_colors.dart';
import 'glossary_data.dart';
import 'glossary_tooltip.dart';

class InteractiveTerm extends StatelessWidget {
  final String term;
  final TextStyle? style;

  const InteractiveTerm(
    this.term, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final item = GlossaryData.find(term);

    return GestureDetector(
      onLongPress: item == null
          ? null
          : () {
              GlossaryTooltip.show(context, item);
            },
      child: Text(
        term,
        style: style ??
            const TextStyle(
              color: CrocColors.primary,
              fontWeight: FontWeight.w900,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: CrocColors.primary,
            ),
      ),
    );
  }
}
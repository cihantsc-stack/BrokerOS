import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../design/broker_colors.dart';
import 'glossary_data.dart';
import 'glossary_tooltip.dart';

class InteractiveGlossaryText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const InteractiveGlossaryText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? const TextStyle(
      color: BrokerColors.textSoft,
      fontSize: 15,
      height: 1.45,
      fontWeight: FontWeight.w600,
    );

    final terms = GlossaryData.terms.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    final spans = <TextSpan>[];
    var remaining = text;

    while (remaining.isNotEmpty) {
      String? foundTerm;
      int foundIndex = -1;
      for (final term in terms) {
        final index = remaining.toLowerCase().indexOf(term.toLowerCase());
        if (index >= 0 && (foundIndex == -1 || index < foundIndex)) {
          foundTerm = term;
          foundIndex = index;
        }
      }
      if (foundTerm == null) {
        spans.add(TextSpan(text: remaining, style: baseStyle));
        break;
      }
      if (foundIndex > 0) {
        spans.add(TextSpan(text: remaining.substring(0, foundIndex), style: baseStyle));
      }
      final matchedText = remaining.substring(foundIndex, foundIndex + foundTerm.length);
      final item = GlossaryData.find(foundTerm);
      spans.add(TextSpan(
        text: matchedText,
        style: baseStyle.copyWith(
          color: BrokerColors.primary,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: BrokerColors.primary,
        ),
        recognizer: LongPressGestureRecognizer()..onLongPress = () {
          if (item != null) GlossaryTooltip.show(context, item);
        },
      ));
      remaining = remaining.substring(foundIndex + foundTerm.length);
    }

    return RichText(text: TextSpan(children: spans));
  }
}

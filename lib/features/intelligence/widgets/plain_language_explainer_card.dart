import 'package:flutter/material.dart';

import '../../../core/decision/models/croc_decision_result.dart';
import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';

enum _ExplainMode { oneSentence, simple, detailed }

class PlainLanguageExplainerCard extends StatefulWidget {
  final CrocDecisionResult result;

  const PlainLanguageExplainerCard({super.key, required this.result});

  @override
  State<PlainLanguageExplainerCard> createState() =>
      _PlainLanguageExplainerCardState();
}

class _PlainLanguageExplainerCardState
    extends State<PlainLanguageExplainerCard> {
  _ExplainMode _mode = _ExplainMode.oneSentence;

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BANA NASIL ANLAT?',
            style: TextStyle(
              color: BrokerColors.textMain,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Aynı kararı istediğin sadelikte oku.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ModeButton(
                label: 'Tek cümle',
                icon: Icons.short_text_rounded,
                selected: _mode == _ExplainMode.oneSentence,
                onTap: () {
                  setState(() {
                    _mode = _ExplainMode.oneSentence;
                  });
                },
              ),
              _ModeButton(
                label: 'Basit anlat',
                icon: Icons.record_voice_over_rounded,
                selected: _mode == _ExplainMode.simple,
                onTap: () {
                  setState(() {
                    _mode = _ExplainMode.simple;
                  });
                },
              ),
              _ModeButton(
                label: 'Detaylı anlat',
                icon: Icons.menu_book_rounded,
                selected: _mode == _ExplainMode.detailed,
                onTap: () {
                  setState(() {
                    _mode = _ExplainMode.detailed;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 13),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Container(
              key: ValueKey<_ExplainMode>(_mode),
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: BrokerColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: BrokerColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                _textForMode(),
                style: const TextStyle(
                  color: BrokerColors.textMain,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu bölüm yalnızca anlatım biçimini değiştirir; analiz sonucu değişmez.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _textForMode() {
    switch (_mode) {
      case _ExplainMode.oneSentence:
        return _oneSentence();
      case _ExplainMode.simple:
        return _simpleExplanation();
      case _ExplainMode.detailed:
        return _detailedExplanation();
    }
  }

  String _oneSentence() {
    final String decision = widget.result.decision;

    if (decision.contains('GÜÇLÜ AL')) {
      return 'Hisse güçlü görünüyor; stop belirleyerek kademeli alım düşünülebilir.';
    }
    if (decision.contains('SEÇİCİ AL')) {
      return 'Hisse olumlu görünüyor; küçük miktarla ve kontrollü hareket etmek daha güvenli.';
    }
    if (decision.contains('İZLE')) {
      return 'Hisseyi takip et; hemen alım yapmak yerine güçlenmesini bekle.';
    }
    if (decision.contains('TEYİT')) {
      return 'Henüz yeterli güç yok; acele etmeden bekle.';
    }
    return 'Risk yüksek görünüyor; şimdilik yeni işlem açma.';
  }

  String _simpleExplanation() {
    final String decision = widget.result.decision;

    if (decision.contains('GÜÇLÜ AL')) {
      return 'Bu hisseyi iyi çalışan bir araba gibi düşün. Motoru güçlü ve yakıtı var. '
          'Yol tamamen risksiz değil; bu yüzden tek seferde yüksek miktarla değil, '
          'kademeli ilerlemek ve zarar sınırına uymak daha güvenli.';
    }
    if (decision.contains('SEÇİCİ AL')) {
      return 'Hissenin görünümü olumlu ama bütün işaretler aynı anda güçlü değil. '
          'Küçük miktarla başlamak veya fiyatın biraz daha güçlenmesini beklemek daha doğru olabilir.';
    }
    if (decision.contains('İZLE')) {
      return 'Hisse kötü görünmüyor fakat henüz yeterince güçlü değil. '
          'Favoriye ekleyip biraz daha veri oluşmasını beklemek daha güvenli.';
    }
    if (decision.contains('TEYİT')) {
      return 'Alıcılar ve satıcılar arasında net bir üstünlük oluşmamış. '
          'Şu anda en doğru hareket beklemek ve yeni işaretleri izlemek.';
    }
    return 'Bu hissede olumsuz işaretler daha fazla. '
        'Paranı korumak için şimdilik uzak durmak daha güvenli.';
  }

  String _detailedExplanation() {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln(
      'CROC AI kararı: ${widget.result.decision}. '
      'Güven seviyesi %${widget.result.confidence}.',
    );
    buffer.writeln();
    buffer.writeln('Kararı destekleyen başlıca nedenler:');

    for (final String reason in widget.result.reasons.take(3)) {
      buffer.writeln('• $reason');
    }

    buffer.writeln();
    buffer.write(
      'Tahmini işlem süresi ${widget.result.tradeWindow}. '
      'Risk seviyesi ${widget.result.risk}. '
      'İşlem yapılacaksa giriş, hedef ve zarar sınırı birlikte değerlendirilmelidir.',
    );

    return buffer.toString();
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? BrokerColors.primary.withValues(alpha: 0.13)
          : BrokerColors.primary.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected
                  ? BrokerColors.primary.withValues(alpha: 0.35)
                  : BrokerColors.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? BrokerColors.primary : BrokerColors.textSoft,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? BrokerColors.primary
                      : BrokerColors.textSoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

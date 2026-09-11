import 'package:flutter/material.dart';

import '../models/decision_models.dart';
import 'decision_theme.dart';

class MarketModeCard extends StatelessWidget {
  final DecisionSnapshot snapshot;

  const MarketModeCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DecisionTheme.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DecisionTheme.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BUGÜNKÜ PİYASA KARARI',
                style: TextStyle(
                  color: DecisionTheme.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.marketMode,
                style: TextStyle(
                  color: DecisionTheme.green,
                  fontSize: compact ? 25 : 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.marketSummary,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.55,
                  fontSize: 13,
                ),
              ),
            ],
          );

          final score = Container(
            width: compact ? double.infinity : 170,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DecisionTheme.panelStrong,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DecisionTheme.border),
            ),
            child: Column(
              children: [
                Text(
                  '${snapshot.marketConfidence}',
                  style: const TextStyle(
                    color: DecisionTheme.green,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  'GÜVEN',
                  style: TextStyle(
                    color: DecisionTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );

          return compact
              ? Column(children: [summary, const SizedBox(height: 16), score])
              : Row(
                  children: [
                    Expanded(child: summary),
                    const SizedBox(width: 20),
                    score,
                  ],
                );
        },
      ),
    );
  }
}

class OpportunityStrip extends StatelessWidget {
  final List<DecisionSignal> signals;
  final String selectedCode;
  final ValueChanged<String> onSelected;

  const OpportunityStrip({
    super.key,
    required this.signals,
    required this.selectedCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: signals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final signal = signals[index];
          final selected = signal.code == selectedCode;
          final positive = signal.changePercent >= 0;

          return InkWell(
            onTap: () => onSelected(signal.code),
            borderRadius: BorderRadius.circular(17),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 220,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: selected
                    ? DecisionTheme.panelStrong
                    : DecisionTheme.panel,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: selected ? DecisionTheme.green : DecisionTheme.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          signal.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${signal.confidence}',
                        style: const TextStyle(
                          color: DecisionTheme.green,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    signal.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DecisionTheme.muted,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${signal.price.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${positive ? '+' : ''}${signal.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: positive ? DecisionTheme.green : DecisionTheme.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    signal.direction.title,
                    style: const TextStyle(
                      color: DecisionTheme.greenSoft,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FinalDecisionCard extends StatelessWidget {
  final DecisionSignal signal;

  const FinalDecisionCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final metrics = <Widget>[
      _Metric(
        title: 'ALIM BÖLGESİ',
        value:
            '${signal.buyLow.toStringAsFixed(2)}–${signal.buyHigh.toStringAsFixed(2)}',
      ),
      _Metric(title: 'İLK HEDEF', value: signal.firstTarget.toStringAsFixed(2)),
      _Metric(title: 'ANA HEDEF', value: signal.mainTarget.toStringAsFixed(2)),
      _Metric(
        title: 'STOP',
        value: signal.stop.toStringAsFixed(2),
        danger: true,
      ),
      _Metric(
        title: 'AZAMİ POZİSYON',
        value: '%${signal.suggestedPortfolioPercent}',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DecisionTheme.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DecisionTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 9,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                signal.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                signal.direction.title,
                style: const TextStyle(
                  color: DecisionTheme.green,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              _Pill(label: 'Güven %${signal.confidence}'),
              _Pill(label: 'Risk ${signal.risk}'),
              _Pill(label: signal.horizon),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            signal.company,
            style: const TextStyle(color: DecisionTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth < 720 ? 2 : 5;
              final itemWidth =
                  (constraints.maxWidth - ((columns - 1) * 10)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: metrics
                    .map((item) => SizedBox(width: itemWidth, child: item))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'NEDEN?',
            style: TextStyle(
              color: DecisionTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...signal.reasons.map(
            (e) => _ReasonRow(
              icon: Icons.check_circle_rounded,
              text: e,
              color: DecisionTheme.green,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SENARYO NE ZAMAN BOZULUR?',
            style: TextStyle(
              color: DecisionTheme.muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...signal.invalidationRules.map(
            (e) => _ReasonRow(
              icon: Icons.warning_amber_rounded,
              text: e,
              color: DecisionTheme.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class FactorGrid extends StatelessWidget {
  final List<AnalysisFactor> factors;

  const FactorGrid({super.key, required this.factors});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;
        final width = (constraints.maxWidth - ((count - 1) * 10)) / count;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: factors
              .map(
                (f) => SizedBox(
                  width: width,
                  child: _FactorCard(factor: f),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _FactorCard extends StatelessWidget {
  final AnalysisFactor factor;

  const _FactorCard({required this.factor});

  @override
  Widget build(BuildContext context) {
    final color = switch (factor.state) {
      FactorState.positive => DecisionTheme.green,
      FactorState.neutral => DecisionTheme.amber,
      FactorState.negative => DecisionTheme.red,
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 138),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DecisionTheme.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DecisionTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  factor.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${factor.score}',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: factor.score / 100,
              backgroundColor: const Color(0xFF173227),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            factor.detail,
            style: const TextStyle(
              color: DecisionTheme.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: DecisionTheme.panelStrong,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: DecisionTheme.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: DecisionTheme.greenSoft,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final bool danger;
  const _Metric({
    required this.title,
    required this.value,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: DecisionTheme.panelStrong,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DecisionTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: DecisionTheme.muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: danger ? DecisionTheme.red : DecisionTheme.green,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _ReasonRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

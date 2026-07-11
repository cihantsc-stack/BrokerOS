import 'package:flutter/material.dart';

import '../../core/engine/broker_engine.dart';
import '../../features/intelligence/broker_intelligence_screen.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/glossary/interactive_glossary_text.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';

class RadarScreen extends StatelessWidget {
  const RadarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stocks = BrokerEngine.run();

    return BrokerPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RadarHeader(),
          const SizedBox(height: 18),
          ...stocks.map(
            (stock) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RadarStockCard(
                symbol: stock.symbol,
                company: stock.company,
                decision: stock.decision,
                risk: stock.risk,
                aiScore: stock.aiScore,
                confidence: stock.confidence,
                reasons: stock.reasons,
                lastPrice: stock.lastPrice,
                dailyChange: stock.dailyChange,
                smartMoneyFlow: stock.smartMoneyFlow,
                firstInstitution: stock.firstInstitution,
                secondInstitution: stock.secondInstitution,
                thirdInstitution: stock.thirdInstitution,
                onOpenReport: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BrokerIntelligenceScreen(symbol: stock.symbol),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarHeader extends StatelessWidget {
  const _RadarHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Radar',
          style: TextStyle(
            color: BrokerColors.textMain,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'CROC AI bugün filtreyi geçen en güçlü fırsatları taradı.',
          style: TextStyle(
            color: BrokerColors.textSoft,
            fontSize: 15,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _RadarStockCard extends StatelessWidget {
  final String symbol;
  final String company;
  final String decision;
  final String risk;
  final int aiScore;
  final int confidence;
  final List<String> reasons;
  final double? lastPrice;
  final double? dailyChange;
  final double? smartMoneyFlow;
  final String? firstInstitution;
  final String? secondInstitution;
  final String? thirdInstitution;
  final VoidCallback onOpenReport;

  const _RadarStockCard({
    required this.symbol,
    required this.company,
    required this.decision,
    required this.risk,
    required this.aiScore,
    required this.confidence,
    required this.reasons,
    required this.lastPrice,
    required this.dailyChange,
    required this.smartMoneyFlow,
    required this.firstInstitution,
    required this.secondInstitution,
    required this.thirdInstitution,
    required this.onOpenReport,
  });

  String _money(double? value) {
    if (value == null) return '--';
    if (value >= 1000000000) {
      return '+${(value / 1000000000).toStringAsFixed(2)} Milyar';
    }
    if (value >= 1000000) {
      return '+${(value / 1000000).toStringAsFixed(0)} Milyon';
    }
    return '+${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isStrong = aiScore >= 90;
    final change = dailyChange ?? 0;
    final changeColor = change >= 0 ? BrokerColors.green : BrokerColors.red;
    final riskColor = risk == 'Orta' ? BrokerColors.orange : BrokerColors.green;
    final expectedMove = symbol == 'ASELS'
        ? '+%7.2'
        : symbol == 'THYAO'
            ? '+%5.8'
            : '+%4.4';

    return BrokerCard(
      glow: isStrong,
      onTap: onOpenReport,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 52,
            child: _MiniSparkline(
              up: change >= 0,
              strength: aiScore,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: BrokerColors.primary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${lastPrice?.toStringAsFixed(2) ?? '--'} ₺',
                          style: const TextStyle(
                            color: BrokerColors.textMain,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: changeColor.withOpacity(.14),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: changeColor.withOpacity(.22),
                            ),
                          ),
                          child: Text(
                            '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: changeColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      company,
                      style: const TextStyle(
                        color: BrokerColors.textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreCircle(score: aiScore),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Mini(
                  title: 'Karar',
                  value: decision,
                  color: decision.contains('AL')
                      ? BrokerColors.green
                      : BrokerColors.orange,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Mini(
                  title: 'Risk',
                  value: risk,
                  color: riskColor,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _Mini(
                  title: 'Güven',
                  value: '%$confidence',
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          InteractiveGlossaryText(
            'Neden: ${reasons.join(", ")}. Smart Money ve Momentum birlikte okunur.',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  title: 'Kurumsal Para',
                  value: _money(smartMoneyFlow),
                  subtitle: 'Son 60 dk',
                  icon: Icons.account_balance_rounded,
                  color: BrokerColors.green,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _InfoBox(
                  title: 'Beklenen Hareket',
                  value: expectedMove,
                  subtitle: '3-5 Gün',
                  icon: Icons.trending_up_rounded,
                  color: BrokerColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _InstitutionBox(
            first: firstInstitution ?? 'İş Yatırım',
            second: secondInstitution ?? 'Ak Yatırım',
            third: thirdInstitution ?? 'Yapı Kredi',
          ),
          const SizedBox(height: 13),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _IconAction(icon: Icons.star_border_rounded, text: 'Favori'),
              _IconAction(icon: Icons.notifications_none_rounded, text: 'Alarm'),
              _IconAction(icon: Icons.show_chart_rounded, text: 'Grafik'),
              _IconAction(
                icon: Icons.psychology_alt_rounded,
                text: 'AI',
                onTap: onOpenReport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final bool up;
  final int strength;

  const _MiniSparkline({
    required this.up,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(up: up, strength: strength),
      child: Container(),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final bool up;
  final int strength;

  _SparklinePainter({
    required this.up,
    required this.strength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = BrokerColors.borderSoft.withOpacity(.40)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = up
        ? [
            Offset(0, size.height * .72),
            Offset(size.width * .14, size.height * .62),
            Offset(size.width * .28, size.height * .66),
            Offset(size.width * .42, size.height * .47),
            Offset(size.width * .56, size.height * .54),
            Offset(size.width * .70, size.height * .32),
            Offset(size.width * .84, size.height * .38),
            Offset(size.width, size.height * .18),
          ]
        : [
            Offset(0, size.height * .30),
            Offset(size.width * .14, size.height * .42),
            Offset(size.width * .28, size.height * .35),
            Offset(size.width * .42, size.height * .50),
            Offset(size.width * .56, size.height * .48),
            Offset(size.width * .70, size.height * .63),
            Offset(size.width * .84, size.height * .58),
            Offset(size.width, size.height * .74),
          ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    final glowPaint = Paint()
      ..color = (up ? BrokerColors.primary : BrokerColors.red).withOpacity(.22)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = up ? BrokerColors.primary : BrokerColors.red
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InstitutionBox extends StatelessWidget {
  final String first;
  final String second;
  final String third;

  const _InstitutionBox({
    required this.first,
    required this.second,
    required this.third,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İlk 3 Kurum',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _InstitutionRow(rank: '1', name: first, amount: '+423.6M'),
          _InstitutionRow(rank: '2', name: second, amount: '+198.7M'),
          _InstitutionRow(rank: '3', name: third, amount: '+156.8M'),
        ],
      ),
    );
  }
}

class _InstitutionRow extends StatelessWidget {
  final String rank;
  final String name;
  final String amount;

  const _InstitutionRow({
    required this.rank,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BrokerColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
              border: Border.all(color: BrokerColors.primary.withOpacity(.22)),
            ),
            child: Text(
              rank,
              style: const TextStyle(
                color: BrokerColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: BrokerColors.textMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              color: BrokerColors.green,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InfoBox({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const _IconAction({
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: BrokerColors.primary, size: 21),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int score;

  const _ScoreCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 5,
            backgroundColor: BrokerColors.borderSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(
              BrokerColors.primary,
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              color: BrokerColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _Mini({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BrokerColors.cardSoft.withOpacity(.75),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: BrokerColors.borderSoft),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
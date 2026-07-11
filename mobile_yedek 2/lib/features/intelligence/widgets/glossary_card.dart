import 'package:flutter/material.dart';

import '../../../shared/design/broker_colors.dart';
import '../../../shared/widgets/broker_card.dart';
import '../../../shared/widgets/glossary_term.dart';

class GlossaryCard extends StatelessWidget {
  const GlossaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_rounded, color: BrokerColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tıklanabilir Borsa Sözlüğü',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Terime dokun, kısa açıklamasını baloncukta gör.',
            style: TextStyle(color: BrokerColors.textSoft, height: 1.35),
          ),
          SizedBox(height: 14),
          Wrap(
            children: [
              GlossaryTerm(
                term: 'Smart Money',
                explanation:
                    'Büyük yatırımcıların, kurumların veya profesyonel paranın piyasadaki hareketini anlatır. Broker OS bunu para izi olarak okur.',
              ),
              GlossaryTerm(
                term: 'Momentum',
                explanation:
                    'Hissenin yükseliş veya düşüş hızıdır. Güçlü momentum, hareketin devam etme ihtimalini artırabilir.',
              ),
              GlossaryTerm(
                term: 'Stop',
                explanation:
                    'Zararın büyümemesi için önceden belirlenen çıkış seviyesidir. Bu seviye kırılırsa işlem fikri bozulabilir.',
              ),
              GlossaryTerm(
                term: 'Direnç',
                explanation:
                    'Fiyatın yükselirken zorlandığı bölgedir. Dirence yakın alım yapmak riskli olabilir.',
              ),
              GlossaryTerm(
                term: 'Volatilite',
                explanation:
                    'Fiyatın kısa sürede ne kadar sert dalgalandığını gösterir. Volatilite arttıkça risk de artar.',
              ),
              GlossaryTerm(
                term: 'MACD',
                explanation:
                    'Trendin yönünü ve momentum değişimini gösteren teknik analiz göstergesidir. Tek başına karar için yeterli değildir.',
              ),
              GlossaryTerm(
                term: 'RSI',
                explanation:
                    'Hissenin aşırı alım veya aşırı satım bölgesine yaklaşıp yaklaşmadığını gösteren teknik göstergedir.',
              ),
              GlossaryTerm(
                term: 'Broker Consensus',
                explanation:
                    'Broker OS’un teknik analiz, kurum akışı, haber, momentum ve risk verilerini birleştirerek oluşturduğu ortak karar puanıdır.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

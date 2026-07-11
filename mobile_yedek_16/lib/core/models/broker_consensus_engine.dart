import '../models/broker_consensus.dart';

class BrokerConsensusEngine {

  static BrokerConsensus calculate(){

    return const BrokerConsensus(

      score:92,

      decision:"GÜÇLÜ AL",

      buySignals:18,

      holdSignals:4,

      sellSignals:1,

      positives:[

        "Smart Money",

        "MACD",

        "EMA20",

        "EMA50",

        "RSI",

        "Kurumsal Para",

        "Yabancı Alımı",

        "Fon Girişi",

        "Haber Analizi"

      ],

      negatives:[

        "Volatilite orta"

      ],

    );

  }

}
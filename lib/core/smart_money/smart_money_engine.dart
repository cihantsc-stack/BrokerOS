import 'institutional_order.dart';
import 'money_flow_point.dart';
import 'smart_money_snapshot.dart';

class SmartMoneyEngine {
  SmartMoneyEngine._();

  static final SmartMoneyEngine instance = SmartMoneyEngine._();

  Future<SmartMoneySnapshot> analyze(String symbol) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final DateTime now = DateTime.now();

    final int seed = symbol.codeUnits.fold<int>(
      0,
      (int total, int value) => total + value,
    );

    final double accumulation = 68.0 + (seed % 19).toDouble();
    final double distribution = 22.0 + (seed % 17).toDouble();

    return SmartMoneySnapshot(
      symbol: symbol,
      institutions: const <InstitutionalOrder>[
        InstitutionalOrder(
          institution: 'İş Yatırım',
          netAmountMillion: 42.5,
          side: InstitutionalOrderSide.buy,
        ),
        InstitutionalOrder(
          institution: 'Yapı Kredi Yatırım',
          netAmountMillion: 31.8,
          side: InstitutionalOrderSide.buy,
        ),
        InstitutionalOrder(
          institution: 'Ak Yatırım',
          netAmountMillion: 28.4,
          side: InstitutionalOrderSide.buy,
        ),
        InstitutionalOrder(
          institution: 'Garanti Yatırım',
          netAmountMillion: -19.2,
          side: InstitutionalOrderSide.sell,
        ),
        InstitutionalOrder(
          institution: 'Vakıf Yatırım',
          netAmountMillion: -11.8,
          side: InstitutionalOrderSide.sell,
        ),
      ],
      moneyFlow: <MoneyFlowPoint>[
        MoneyFlowPoint(
          time: now.subtract(const Duration(minutes: 30)),
          netFlowMillion: 8.0,
        ),
        MoneyFlowPoint(
          time: now.subtract(const Duration(minutes: 25)),
          netFlowMillion: 13.5,
        ),
        MoneyFlowPoint(
          time: now.subtract(const Duration(minutes: 20)),
          netFlowMillion: 18.0,
        ),
        MoneyFlowPoint(
          time: now.subtract(const Duration(minutes: 15)),
          netFlowMillion: 26.5,
        ),
        MoneyFlowPoint(
          time: now.subtract(const Duration(minutes: 10)),
          netFlowMillion: 24.0,
        ),
        MoneyFlowPoint(
          time: now.subtract(const Duration(minutes: 5)),
          netFlowMillion: 34.5,
        ),
        MoneyFlowPoint(time: now, netFlowMillion: 41.0),
      ],
      hiddenAccumulationScore: accumulation.clamp(0.0, 100.0),
      distributionRisk: distribution.clamp(0.0, 100.0),
      largeOrderLots: 950000.0 + ((seed % 7) * 50000).toDouble(),
      largeOrderSide: InstitutionalOrderSide.buy,
      largeOrderTime: now.subtract(const Duration(minutes: 7)),
      aiComment:
          'Son 45 dakikada kurumsal alımlar bireysel satışlardan '
          '2,8 kat güçlü. Toplanma ihtimali yüksek, ancak hacim '
          'devamlılığı izlenmeli.',
    );
  }
}

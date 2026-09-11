import '../../data_terminal/models/institutional_models.dart';
import '../../data_terminal/repositories/institutional_repository.dart';

class InstitutionalRadarResult {
  final String symbol;
  final bool providerConnected;
  final String providerName;
  final String statusMessage;
  final int score;
  final String signal;
  final List<BrokerFlow> topBuyers;
  final List<BrokerFlow> topSellers;
  final DateTime? updatedAt;

  const InstitutionalRadarResult({
    required this.symbol,
    required this.providerConnected,
    required this.providerName,
    required this.statusMessage,
    required this.score,
    required this.signal,
    required this.topBuyers,
    required this.topSellers,
    required this.updatedAt,
  });
}

class InstitutionalRadarService {
  InstitutionalRadarService._();

  static final InstitutionalRadarService instance =
      InstitutionalRadarService._();

  final InstitutionalRepository _repository = InstitutionalRepository();

  Future<InstitutionalRadarResult> load(String symbol) async {
    final data = await _repository.load(symbol);

    if (!data.providerConnected || !data.hasBrokerFlows) {
      return InstitutionalRadarResult(
        symbol: symbol,
        providerConnected: false,
        providerName: data.providerName,
        statusMessage: data.statusMessage,
        score: 50,
        signal: 'VERİ BEKLENİYOR',
        topBuyers: const [],
        topSellers: const [],
        updatedAt: data.updatedAt,
      );
    }

    final flows = List<BrokerFlow>.from(data.brokerFlows);

    final buyers = flows.where((e) => e.netAmount > 0).toList()
      ..sort((a, b) => b.netAmount.compareTo(a.netAmount));

    final sellers = flows.where((e) => e.netAmount < 0).toList()
      ..sort((a, b) => a.netAmount.compareTo(b.netAmount));

    final score = _score(flows);

    final signal = score >= 70
        ? 'ALIM DESTEĞİ'
        : score <= 35
        ? 'SATIŞ BASKISI'
        : 'NÖTR';

    return InstitutionalRadarResult(
      symbol: symbol,
      providerConnected: true,
      providerName: data.providerName,
      statusMessage: data.statusMessage,
      score: score,
      signal: signal,
      topBuyers: buyers.take(3).toList(growable: false),
      topSellers: sellers.take(3).toList(growable: false),
      updatedAt: data.updatedAt,
    );
  }

  int _score(List<BrokerFlow> flows) {
    if (flows.isEmpty) return 50;

    final totalAbsNet = flows.fold<double>(
      0,
      (sum, item) => sum + item.netAmount.abs(),
    );

    if (totalAbsNet <= 0) return 50;

    final netTotal = flows.fold<double>(0, (sum, item) => sum + item.netAmount);

    final directional = (netTotal / totalAbsNet).clamp(-1.0, 1.0);

    final sorted = List<BrokerFlow>.from(flows)
      ..sort((a, b) => b.netAmount.abs().compareTo(a.netAmount.abs()));

    final top3Abs = sorted
        .take(3)
        .fold<double>(0, (sum, item) => sum + item.netAmount.abs());

    final concentration = (top3Abs / totalAbsNet).clamp(0.0, 1.0);

    var score = 50.0;

    score += directional * 30;

    if (directional > 0) {
      score += concentration * 8;
    } else if (directional < 0) {
      score -= concentration * 8;
    }

    return score.round().clamp(5, 95);
  }
}

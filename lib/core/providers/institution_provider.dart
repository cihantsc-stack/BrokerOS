class InstitutionFlowData {
  final String symbol;
  final double netFlow;
  final int score;
  final List<String> leadingInstitutions;
  final DateTime updatedAt;
  final bool available;
  final String status;

  const InstitutionFlowData({
    required this.symbol,
    required this.netFlow,
    required this.score,
    required this.leadingInstitutions,
    required this.updatedAt,
    this.available = false,
    this.status = 'Kurumsal veri kaynagi bekleniyor',
  });
}

abstract interface class InstitutionProvider {
  Future<InstitutionFlowData> fetch(String symbol);
}

class UnavailableInstitutionProvider implements InstitutionProvider {
  const UnavailableInstitutionProvider();

  @override
  Future<InstitutionFlowData> fetch(String symbol) async {
    return InstitutionFlowData(
      symbol: symbol.trim().toUpperCase().replaceAll('.IS', ''),
      netFlow: 0,
      score: 0,
      leadingInstitutions: const [],
      updatedAt: DateTime.now(),
      available: false,
      status: 'GERCEK KURUMSAL VERI KAYNAGI BEKLENIYOR',
    );
  }
}

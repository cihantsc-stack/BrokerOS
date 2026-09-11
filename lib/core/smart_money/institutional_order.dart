enum InstitutionalOrderSide { buy, sell }

extension InstitutionalOrderSideLabel on InstitutionalOrderSide {
  String get label {
    switch (this) {
      case InstitutionalOrderSide.buy:
        return 'ALICI';
      case InstitutionalOrderSide.sell:
        return 'SATICI';
    }
  }
}

class InstitutionalOrder {
  final String institution;
  final double netAmountMillion;
  final InstitutionalOrderSide side;

  const InstitutionalOrder({
    required this.institution,
    required this.netAmountMillion,
    required this.side,
  });
}

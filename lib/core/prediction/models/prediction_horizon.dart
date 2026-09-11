enum PredictionHorizon { oneDay, fiveDays, twentyDays }

extension PredictionHorizonX on PredictionHorizon {
  int get tradingDays {
    switch (this) {
      case PredictionHorizon.oneDay: return 1;
      case PredictionHorizon.fiveDays: return 5;
      case PredictionHorizon.twentyDays: return 20;
    }
  }

  String get label {
    switch (this) {
      case PredictionHorizon.oneDay: return '1 Gün';
      case PredictionHorizon.fiveDays: return '5 Gün';
      case PredictionHorizon.twentyDays: return '20 Gün';
    }
  }
}

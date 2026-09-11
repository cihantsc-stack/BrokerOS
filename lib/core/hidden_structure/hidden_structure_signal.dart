enum HiddenStructureLevel { low, medium, high, veryHigh }

extension HiddenStructureLevelLabel on HiddenStructureLevel {
  String get label {
    switch (this) {
      case HiddenStructureLevel.low:
        return 'DÜŞÜK';
      case HiddenStructureLevel.medium:
        return 'ORTA';
      case HiddenStructureLevel.high:
        return 'YÜKSEK';
      case HiddenStructureLevel.veryHigh:
        return 'ÇOK YÜKSEK';
    }
  }
}

class HiddenStructureSignal {
  final String title;
  final String description;
  final double score;
  final HiddenStructureLevel level;

  const HiddenStructureSignal({
    required this.title,
    required this.description,
    required this.score,
    required this.level,
  });
}

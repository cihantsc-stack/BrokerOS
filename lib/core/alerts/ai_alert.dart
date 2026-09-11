enum AiAlertSeverity { info, warning, critical }

class AiAlert {
  final String id;
  final String symbol;
  final String title;
  final String description;
  final AiAlertSeverity severity;
  final DateTime createdAt;
  final bool isRead;

  const AiAlert({
    required this.id,
    required this.symbol,
    required this.title,
    required this.description,
    required this.severity,
    required this.createdAt,
    this.isRead = false,
  });

  AiAlert copyWith({bool? isRead}) {
    return AiAlert(
      id: id,
      symbol: symbol,
      title: title,
      description: description,
      severity: severity,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

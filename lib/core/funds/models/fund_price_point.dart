class FundPricePoint {
  final DateTime date;
  final double price;

  const FundPricePoint({required this.date, required this.price});

  factory FundPricePoint.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date']?.toString() ?? '';
    final rawPrice = json['price'];

    final parsedDate = DateTime.tryParse(rawDate);

    final double? parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '');

    if (parsedDate == null || parsedPrice == null || parsedPrice <= 0) {
      throw const FormatException('Gecersiz fon fiyat noktasi.');
    }

    return FundPricePoint(date: parsedDate, price: parsedPrice);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StockLogo extends StatelessWidget {
  final String code;
  final double size;

  const StockLogo({super.key, required this.code, this.size = 45});

  static const Map<String, String> _assets = {
    'ASELS': 'assets/stock_logos/asels.svg',
    'THYAO': 'assets/stock_logos/thyao.svg',
    'AKBNK': 'assets/stock_logos/akbnk.svg',
    'GARAN': 'assets/stock_logos/garan.svg',
    'KCHOL': 'assets/stock_logos/kchol.svg',
    'SAHOL': 'assets/stock_logos/sahol.svg',
    'BIMAS': 'assets/stock_logos/bimas.svg',
    'EREGL': 'assets/stock_logos/eregl.svg',
  };

  @override
  Widget build(BuildContext context) {
    final normalizedCode = code.trim().toUpperCase();
    final asset = _assets[normalizedCode];

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF235844)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF70F4AD).withValues(alpha: 0.07),
            blurRadius: 10,
          ),
        ],
      ),
      child: asset == null
          ? _FallbackLogo(code: normalizedCode)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: SvgPicture.asset(
                  asset,
                  fit: BoxFit.contain,
                  placeholderBuilder: (_) {
                    return _FallbackLogo(code: normalizedCode);
                  },
                ),
              ),
            ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  final String code;

  const _FallbackLogo({required this.code});

  @override
  Widget build(BuildContext context) {
    final label = code.isEmpty
        ? '?'
        : code.length >= 2
        ? code.substring(0, 2)
        : code.substring(0, 1);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123D2D), Color(0xFF071C15)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF70F4AD),
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

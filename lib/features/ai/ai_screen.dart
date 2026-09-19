import 'package:flutter/material.dart';

import '../stock_detail/screens/stock_detail_screen.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'ASELS',
  );

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openStock() {
    final symbol = _controller.text.trim().toUpperCase();

    if (!RegExp(r'^[A-Z0-9]{3,6}$').hasMatch(symbol)) {
      setState(() {
        _error = 'Geçerli bir BIST hisse kodu yaz. Örn: ASELS, KOCMT, THYAO';
      });
      return;
    }

    setState(() => _error = null);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(
          code: symbol,
          company: symbol,
          price: 0,
          change: 0,
          aiScore: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020807),
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          _hero(),
          const SizedBox(height: 14),
          _searchCard(),
          const SizedBox(height: 14),
          _whatYouGet(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071812), Color(0xFF04100C), Color(0xFF020807)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1D6549)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2200FF9D),
            blurRadius: 26,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0B2118),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2A8E63)),
            ),
            child: const Icon(
              Icons.candlestick_chart_rounded,
              color: Color(0xFF6CF0AD),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CROC HİSSE MERKEZİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .3,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Bir hisse. Tek ekran. Tek karar.',
                  style: TextStyle(
                    color: Color(0xFF6CF0AD),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Hisseyi yaz; CROC canlı fiyatı, grafiği, teknik yapıyı ve riski tek yerde toplasın.',
                  style: TextStyle(
                    color: Color(0xFF9BAFA7),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF092118),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: const Color(0xFF2A8E63)),
            ),
            child: const Text(
              'CANLI VERİ',
              style: TextStyle(
                color: Color(0xFF6CF0AD),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF050F0C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF183C2F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HANGİ HİSSEYE BAKALIM?',
            style: TextStyle(
              color: Color(0xFF91A69E),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _openStock(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ASELS, KOCMT, THYAO, TUPRS...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF63766F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6CF0AD),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF071713),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1D513D)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF1D513D)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF6CF0AD),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 55,
                child: FilledButton.icon(
                  onPressed: _openStock,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF23A86E),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text(
                    'CROC NE DİYOR?',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFFFF747A), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _whatYouGet() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 30) / 4
            : (constraints.maxWidth - 10) / 2;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _miniCard(
              width,
              Icons.gavel_rounded,
              'KARAR',
              'AL / BEKLE / RİSK AZALT',
            ),
            _miniCard(
              width,
              Icons.route_rounded,
              'PLAN',
              'Alım • Hedef • Stop',
            ),
            _miniCard(
              width,
              Icons.show_chart_rounded,
              'GRAFİK',
              'Canlı mumlar • Destek • Direnç',
            ),
            _miniCard(
              width,
              Icons.query_stats_rounded,
              'TAHMİN',
              '1 / 5 / 20 günlük beklenti',
            ),
          ],
        );
      },
    );
  }

  Widget _miniCard(double width, IconData icon, String title, String subtitle) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF050F0C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF17372C)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0A2118),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6CF0AD), size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF81948D),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

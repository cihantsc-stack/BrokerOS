import 'package:flutter/material.dart';

import '../../features/intelligence/broker_intelligence_screen.dart';
import '../../shared/design/broker_colors.dart';
import '../../shared/widgets/broker_card.dart';
import '../../shared/widgets/broker_page.dart';
import '../../shared/widgets/page_title.dart';

class ExperienceCenterScreen extends StatefulWidget {
  const ExperienceCenterScreen({super.key});

  @override
  State<ExperienceCenterScreen> createState() => _ExperienceCenterScreenState();
}

class _ExperienceCenterScreenState extends State<ExperienceCenterScreen> {
  final TextEditingController _controller = TextEditingController(
    text: 'ASELS',
  );

  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final symbol = _controller.text.trim().toUpperCase();

    if (symbol.isEmpty) {
      setState(() {
        _error = 'Bir hisse kodu yaz.';
      });
      return;
    }

    if (!RegExp(r'^[A-Z0-9]{3,6}$').hasMatch(symbol)) {
      setState(() {
        _error = 'Geçerli bir BIST hisse kodu yaz. Örn: ASELS, KOCMT, THYAO';
      });
      return;
    }

    setState(() {
      _error = null;
    });

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrokerIntelligenceScreen(symbol: symbol),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrokerColors.background,
      body: BrokerPage(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitle('AI Analiz'),
            const SizedBox(height: 8),
            const Text(
              'Bir hisse seç. CROC sana ne yapacağını sade şekilde anlatsın.',
              style: TextStyle(
                color: BrokerColors.textSoft,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            BrokerCard(
              glow: true,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.psychology_alt_rounded,
                          color: BrokerColors.primary,
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'CROC\'A HİSSE SOR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _analyze(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Hisse kodu: ASELS, KOCMT, THYAO...',
                        hintStyle: const TextStyle(
                          color: BrokerColors.textSoft,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: BrokerColors.primary,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF06120E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF174C38),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF174C38),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: BrokerColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: BrokerColors.red,
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _analyze,
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'CROC NE DİYOR?',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _HowItWorksCard(),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return BrokerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Burada ne göreceğim?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _row(
            Icons.gavel_rounded,
            'Karar',
            'AL / BEKLE / RİSK AZALT / UZAK DUR',
          ),
          const SizedBox(height: 10),
          _row(Icons.route_rounded, 'Plan', 'Alım bölgesi, hedef ve stop'),
          const SizedBox(height: 10),
          _row(
            Icons.query_stats_rounded,
            'Beklenti',
            '1 / 5 / 20 günlük CROC tahmini',
          ),
          const SizedBox(height: 10),
          _row(
            Icons.help_outline_rounded,
            'Neden?',
            'CROC kararının kısa ve anlaşılır gerekçeleri',
          ),
          const SizedBox(height: 12),
          const Text(
            'Teknik göstergeler ve diğer ayrıntılar arkada çalışır. '
            'İstersen analiz ekranında detaylara inebilirsin.',
            style: TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: BrokerColors.primary, size: 19),
        const SizedBox(width: 9),
        SizedBox(
          width: 72,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: BrokerColors.textSoft,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

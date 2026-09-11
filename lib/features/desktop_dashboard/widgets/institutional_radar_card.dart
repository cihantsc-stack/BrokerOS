import 'package:flutter/material.dart';

class InstitutionalRadarCard extends StatelessWidget {
  const InstitutionalRadarCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF173D30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_rounded,
                color: Color(0xFF70F4AD),
                size: 18,
              ),
              SizedBox(width: 7),
              Expanded(
                child: Text(
                  'KURUM RADARI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusBadge(),
            ],
          ),
          SizedBox(height: 9),
          Text(
            'KURUMSAL TARAMA BEKLENİYOR',
            style: TextStyle(
              color: Color(0xFFFFC857),
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "BIST'te kurumların en güçlü net alım yaptığı hisseler "
            "AKD, net alım, takas ve süreklilik verileriyle burada sıralanacak.",
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF83988E),
              fontSize: 8.2,
              height: 1.35,
            ),
          ),
          Spacer(),
          Text(
            'AKD • NET ALIM • TAKAS • SÜREKLİLİK',
            style: TextStyle(
              color: Color(0xFF60776D),
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC857).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: const Color(0xFFFFC857).withValues(alpha: .28),
        ),
      ),
      child: const Text(
        'VERİ BEKLENİYOR',
        style: TextStyle(
          color: Color(0xFFFFC857),
          fontSize: 6.8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/funds/models/stock_fund_radar_result.dart';

class CrocFundRadarCard extends StatelessWidget {
  final StockFundRadarResult? result;
  final bool loading;

  const CrocFundRadarCard({
    super.key,
    required this.result,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF06130F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C4B39)),
      ),
      child: loading ? const _LoadingView() : _buildContent(),
    );
  }

  Widget _buildContent() {
    final data = result;

    if (data == null) {
      return const _UnavailableView(message: 'Fon verisi bekleniyor');
    }

    if (!data.available || data.funds.isEmpty) {
      return _UnavailableView(
        message:
            data.status ??
            'Bu hisse için mevcut snapshotta fon pozisyonu bulunamadı.',
      );
    }

    final visibleFunds = data.funds.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.radar_rounded, size: 20, color: Color(0xFF71E6B0)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'FON RADARI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            if (data.activePeriod != null) _Badge(text: data.activePeriod!),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          'Kurumsal fonların ${data.symbol} pozisyonu',
          style: const TextStyle(color: Color(0xFF8AA39A), fontSize: 12),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Metric(title: 'Fon', value: '${data.holderFundCount}'),
            ),
            Expanded(
              child: _Metric(
                title: 'Toplam Değer',
                value: _compactMoney(data.totalValue),
              ),
            ),
            Expanded(
              child: _Metric(
                title: 'Ort. Ağırlık',
                value: '%${data.averageWeight.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFF17372D)),
        const SizedBox(height: 6),
        for (final fund in visibleFunds) _FundRow(fund: fund),
        if (data.funds.length > visibleFunds.length) ...[
          const SizedBox(height: 5),
          Text(
            '+${data.funds.length - visibleFunds.length} fon daha',
            style: const TextStyle(
              color: Color(0xFF71E6B0),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 8),
        const Text(
          'Kaynak: CROC Fund Holdings Snapshot • Karar motoruna henüz etki etmez',
          style: TextStyle(color: Color(0xFF61776F), fontSize: 10),
        ),
      ],
    );
  }

  static String _compactMoney(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)} Mr ₺';
    }

    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)} Mn ₺';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} Bin ₺';
    }

    return '${value.toStringAsFixed(0)} ₺';
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF71E6B0),
          ),
        ),
        SizedBox(width: 10),
        Text(
          'Fon Radarı taranıyor...',
          style: TextStyle(color: Color(0xFF9CB0A8), fontSize: 12),
        ),
      ],
    );
  }
}

class _UnavailableView extends StatelessWidget {
  final String message;

  const _UnavailableView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.radar_rounded, color: Color(0xFF60756D), size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FON RADARI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                message,
                style: const TextStyle(color: Color(0xFF81958D), fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;

  const _Metric({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF70877E), fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FundRow extends StatelessWidget {
  final StockFundPosition fund;

  const _FundRow({required this.fund});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 42,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF0C251C),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              fund.fundCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF71E6B0),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fund.name ?? fund.symbol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFFC6D2CD), fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '%${fund.weight.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2B20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF71E6B0),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
